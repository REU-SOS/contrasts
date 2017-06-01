# When Models go wrong:

<img align=right width=400 src="https://i0.wp.com/www.spacesafetymagazine.com/wp-content/uploads/2014/05/reentry-breakup.jpg?resize=460%2C316">

Columbia ice strike

- Size: 1200 m2
- Speed: 477 mpg  (relative to vehicle)

Certified as “safe” by the CRATER micro-meteorite model.

- A experiment in CRATER’s  DB:
   - Size: 3cm3
    - Speed: under 100 mpg

Columbia, and crew, dies on re-entry
 
- Lesson: conclusions should come with a “certification envelope” 
- If new tests outside of the envelope of the training set then raise an alert 


# Congitive

![image](https://cloud.githubusercontent.com/assets/29195/26566573/27c63d1c-44c2-11e7-9506-d4294969e171.png)

## Constructivism:

- Knowledge is not universal, laying around like diamonds
     - WRONG: Mind is a passive system that gathers its contents from its environment and, through the act of knowing, produces a copy of the order of reality
- Rather, in the act of knowing, it is the human mind that actively gives meaning and order to that reality to which it is responding
      - We see, we react, then we know
      
e.g. Explanation

- [When explaining something, one size does not fit all](ftp://ftp.cs.indiana.edu/pub/leake/p-91-01.pdf). Explanations need to be tailored to the knowledge and goals of the audience. 

e.g. Kelly's personel construct theory:

- humans reason about the difference between our constructs rather than the constructs themselves
- Kelly, George (1991) [first publsihed 1955]. The psychology of personal constructs. London; New York: Routledge in association with the Centre for Personal Construct Psychology. ISBN 0415037999. OCLC 21760190.

my Spiel would be cognitive. that stats are "m'eh" but the real game is showing decision makers  things that let them do things. so informative "visualizations" that highligtht the deltas between things (Kelly's personnel construct theory: folks dont know "things", what they really know are the minimal differences between things) .

which leads to the mathematics of diversity (entropy, variance) and how to distinguish between things (bootstrapping, effectSize) and how to apply that theory of differences to data mining (clustering, discretization, recursive tree learning).  

the final cherry on this cake would be scott-knot stuff seen at icse recently where  results are chunked up into BIG groups and we no longer focus on micro deltas but on BIG MOFO DIFFERENCES.

so not sure if that is an REU thing or a lecture for my foundations of software science thing in the fall

your call. happy to help. happy to not. what ya need?

## Don't sweat the small stuff

Don't divide data if the division is smaller than some _epsilon_ 

- e.g. something less than what the business users can control
- e.g. some small fraction of the standard devaition 
      - _Cohen_ is a heuristic for detecting tricially small differences. Trivial if less than _cohen\*sd_  different
      - Cohen=(0.2,0.5,0.8) = small, medium, large
      - But this is [somewhat contraversial](https://en.wikipedia.org/wiki/Effect_size#Effect_sizes_descriptors)

Don't seperate distributions if their mean difference is very small and/or their variance is large

![e.g.](https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/Normal_Distribution_PDF.svg/720px-Normal_Distribution_PDF.svg.png)

- [A class for collecting means and standard deviations](https://github.com/golden/src/blob/master/cognitive.gold#L121-L130)
- [incremental computation of var, mean](https://github.com/golden/src/blob/master/cognitive.gold#L131-L144)
- [detecting different distributions](https://github.com/golden/src/blob/master/cognitive.gold#L121-L144)
      - see [these lines](https://github.com/golden/src/blob/master/cognitive.gold#L179-L180) for the core test

Don't divide data if, after the division, the confusion in the result is just the same.

- For numbers, varaince measures confusion
- For symbols,the analog is _entropy_ = number of bits needed to encode a signal  
- eg. yes,yes, yes, no,no = (3/5, 2/5)  
- ent = -1\* sum p\*log2(p) = -1*(2/5\*log2(2/5) + 3/5\*log2(3/5) = 0.97
     
If divisions of data do not decreases varaince/entropy, then that is a bad division:

- e.g. 10 orranges, 5 green apples, 1 watermelon
- before division: ent = -1*(10/16\*log2(10/16) + 5/16\*log2(5/16) + 1/16\*log2(1/16)) = 1.6
- considering dividing on color= orange and color=green
- after division there are 10,6 orange and green things
- ent= -1*(10/16\*log2(10/16) + 6/16\*log2(6/16)) = 0.95
- [code](https://github.com/golden/src/blob/master/cognitive.gold#L353-L380)

Example: consider divisions to a sorted list _nums.all_. Suppose _nums_ can report its standard deviation as _nums.sd_ then..

```c
function binsGrow(t,nums,b,      
                   epsilon,enough,r,ranks,j,most,val) {
  epsilon = nums.sd * b.cohen
  enough  = length( t.rows )^b.m
  most    = last(nums.all)
  has(b.ranks, 1, "Num")
  r = 1
  for(j=1; j<=t.n; j++) {
    val = nums.all[j]
    NumAdd( b.ranks[r], val )
    if ( most - val > epsilon ) 
      if( t.n - j > enough )
        if( b.ranks[r].n > enough )
          if( b.ranks[r].hi - b.ranks[r].lo > epsilon )
            has( b.ranks, ++r, "Num" ) }
  return r
}
```

After the bins are grown, then we can find cuts to the bins that most reduce the _expectedValue_ of the standard devision before and after a cut.

- If there are obs of "_x1_"  and "_x2_" seen in "_n1_" and "_n2_" examples then
- _n=n1+n2_
- Expected value = _E = n1/n \* x1 + n2/n \* x2_

Which the following code uses to recusrively split the bins generated above:

```c
function binsCuts(lo,hi,ranks,b4,r,
                  j,best,n,mid,x,y,xx,yy,tmp,cut) {
  best = b4.sd
  if (lo < hi) 
    for(mid=lo+1; mid<=hi; mid++) {
      xpect(x, lo,    mid, ranks)
      xpect(y, mid+1,  hi, ranks)
      tmp = x.n/b4.n*x.sd + y.n/b4.n*y.sd  
      if (tmp < best)  
        if ( diff(x,y) ) {
          cut  = mid
          best = tmp
          copy(x,xx)
          copy(y,yy)
  }}
  if (cut) {
    r = binsCuts(lo,    cut, ranks, xx, r) + 1 # <== recursive call
    r = binsCuts(cut+1,  hi, ranks, yy, r)
  } else 
     for(j=lo; j<=hi; j++)
       ranks[j].rank= r
  return r
}
```




# Maths that matters

Cognitive maths. Maths that fuels human decision making:

- explaination is task-depnedent: supervised learning rules (different atsks, different learning)
- instance-based reasoning: don't think, rememoer over a small library of examplars
- Don't sweat the small stuff: effect size, scott-knott
- Maths of n-dimensional sphere: low-dimensional or not at all (+)
- Kelly's peresonnel constract theory: dont show what is, show what is different
- Minimize confusion: reduce expected value of variance or entropy

(+) note: cool if we are human intelligence. May not hold for super-human intelligence.


