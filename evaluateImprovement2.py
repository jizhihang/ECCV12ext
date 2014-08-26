#!/usr/bin/python

import os, cv, pdb

#0 == raw accuracy
#1 == as was in paper
#2 == (fixes subtle and rare issue with 3 walls)
EVAL_TYPE = 2


def loadLabels(fn):
    polygons = []
    for line in file(fn).read().split("\n")[:5]:
        line = line.strip()
        if not line:
            polygons.append([])
            continue
        data = map(float, line.split(" "))
        X = [data[i] for i in range(len(data)) if i % 2 == 0]
        Y = [data[i] for i in range(len(data)) if i % 2 == 1]
        polygons.append(zip(X,Y))
    return polygons

def visualizePolygons(image, polygons):
    #note that this modifies the passed image!
    for polygonI,polygon in enumerate(polygons):
        polygon = [(int(p[0]),int(p[1])) for p in polygon]
        cv.FillConvexPoly(image, polygon, polygonI+1, 4)

def getBlankLabelImage(image):
    #basically zeros(size(image))
    labelImage = cv.CreateImage(cv.GetSize(image), cv.IPL_DEPTH_8U, 1)
    cv.Zero(labelImage)
    return labelImage

def evaluatePolygonLabelRaw(polygons, gtImage, maskImage, foundZeros, image):
    #splat the results to an image
    labelImage = getBlankLabelImage(image)
    visualizePolygons(labelImage, polygons)

    #get the label image and rescale it to the correct size, if necessary
    labelImageRescale = cv.CreateImage(cv.GetSize(gtImage),cv.IPL_DEPTH_8U, 1)
    cv.Resize(labelImage, labelImageRescale)
    labelImage = labelImageRescale

    #compute the difference -- this is 0 if correct
    cv.AbsDiff(labelImage, gtImage, labelImage)
    w, h = cv.GetSize(gtImage)

    #mask out unknown values
    cv.Set(labelImage, 1, maskImage)

    #return (Total Pixels - incorrect) / (total pixels)    
    nPixValid = w * h - foundZeros
    return float(w * h - cv.CountNonZero(labelImage)) / nPixValid

def evaluatePolygonLabel(polygons, gtImage, maskImage, foundZeros, image):
    #F,M,R,L,C
    isomorphs = [polygons]
    if EVAL_TYPE != 0:
        # Left =>Middle, Middle=>Right, Right => []
        isomorphs.append([polygons[0],polygons[3],polygons[1],[],polygons[4]])
        # Right=>Middle, Middle=>Left, Left => []
        isomorphs.append([polygons[0],polygons[2],[],polygons[1],polygons[4]])

    scores = []
    for isomorph in isomorphs:
        scores.append(evaluatePolygonLabelRaw(isomorph, gtImage, maskImage, foundZeros, image))

    #if there's no wall missing and we're not allowing renaming 
    if 0 not in map(len,polygons[1:4]) and EVAL_TYPE != 1:
        return scores[0]
    else:
        return max(scores)

def mean(l):
    if len(l) == 0:
        return 0
    return sum(l) / len(l)

def getDigit(fn):
    return int(''.join([c for c in fn if c in '0123456789']))

if __name__ == "__main__":

    #where to load the results from
    resultDir = "results/"
    datasets = [fn for fn in os.listdir(resultDir) if os.path.isdir(resultDir+"/"+fn)]

    #accumulate
    sumDiff, numDiff, diffs = 0.0, 0, []
    newScoresAccum = []
    oldScoresAccum = []
    pixelDiffs = []

    names = []

    #datasets = ['7FleM_h4bbI']
    datasets = sorted(datasets)
    for dataset in datasets:

        #setup
        image = cv.LoadImage("../dataset/images/%s.jpg" % dataset)
        labelImage = cv.LoadImage("../dataset/gt/%s.png" % dataset,0)
        maskImage = getBlankLabelImage(labelImage)
        w, h = cv.GetSize(labelImage)
        foundZeros = 0
        for y in range(h):
            for x in range(w):
                if labelImage[y,x] == 0:
                    foundZeros += 1
                    maskImage[y,x] = 1

        #this originally was for lots of outputs; the code dumps only one
        labels = [fn for fn in os.listdir(resultDir+"/"+dataset+"/") if fn.find("Labels.txt") != -1]
        newLabels, oldLabels = [fn for fn in labels if fn.find("new") != -1], [fn for fn in labels if fn.find("old") != -1]
        newLabels.sort(key=getDigit); oldLabels.sort(key=getDigit)

        #load the labels and then evaluate them
        newPolys = map(lambda s: loadLabels(resultDir+"/"+dataset+"/"+s), newLabels)
        oldPolys = map(lambda s: loadLabels(resultDir+"/"+dataset+"/"+s), oldLabels)
        newScores = map(lambda p: evaluatePolygonLabel(p, labelImage, maskImage, foundZeros, image), newPolys[:1])
        oldScores = map(lambda p: evaluatePolygonLabel(p, labelImage, maskImage, foundZeros, image), oldPolys[:1])

        #for all the scores, write out the results
        for i in range(len(newScores)):
            newLabel, oldLabel = newLabels[i], oldLabels[i]
            newBase = newLabel.replace("Labels.txt","")
            oldBase = oldLabel.replace("Labels.txt","")
            file(resultDir+"/"+dataset+"/"+newBase+"Eval.txt","w").write(str(newScores[i]))
            file(resultDir+"/"+dataset+"/"+oldBase+"Eval.txt","w").write(str(oldScores[i]))


        #just append stuff, plus the difference between the images
        sumDiff += newScores[0] - oldScores[0]
        diffs.append(newScores[0] - oldScores[0])
        newScoresAccum.append(newScores[0])
        oldScoresAccum.append(oldScores[0])
        oldPolyImage = getBlankLabelImage(labelImage)
        visualizePolygons(oldPolyImage,oldPolys[0])
        pixelDiff = evaluatePolygonLabel(newPolys[0], oldPolyImage, maskImage, foundZeros, image)
        pixelDiffs.append(pixelDiff)
        file(resultDir+"/"+dataset+"/pixelDiff.txt","w").write("%f" % pixelDiff)

        numDiff += 1
        names.append(dataset)

    d2 = [v for v in diffs if abs(v) > 0.1]

    print len(pixelDiffs)
    assert len(pixelDiffs) == len(oldScoresAccum)

    print "New Accuracy (PW):", (sum(newScoresAccum) / len(newScoresAccum))*100
    print "Old Accuracy (VH):", (sum(oldScoresAccum) / len(oldScoresAccum))*100
    print "Diff: ", 100*((sum(newScoresAccum) / len(newScoresAccum)) - (sum(oldScoresAccum) / len(oldScoresAccum)))

    f = file("diffs.txt","w"); [f.write("%f\n" % v) for v in diffs]; f.close()
    f = file("diffs2.txt","w"); [f.write("%f\n" % v) for v in d2]; f.close()
    f = file("names.txt","w"); [f.write("%s\n" % n) for n in names]; f.close()
    f = file("pixelDiffs.txt","w"); [f.write("%f\n" % v) for v in pixelDiffs]; f.close()
    f = file("vh.txt","w"); [f.write("%f\n" % v) for v in oldScoresAccum]; f.close()


