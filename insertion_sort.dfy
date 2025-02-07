datatype StateSpace = StateSpace(arr: array<int>,st: int)

predicate sorted(a:array<int>, min:int, max:int)
requires a != null;
requires 0<= min <= max <= a.Length;
reads a;
{
  forall j, k :: min <= j < k < max ==> a[j] <= a[k]
}

function method rho(arr: array<int>): StateSpace
{
    StateSpace(arr,0)
}

function method pi(state: StateSpace): array<int>
{
    state.arr
}
method swap(a: array<int>, i:int, j:int)
  modifies a;
  requires a != null
  requires 0 <= i < j < a.Length
  requires i + 1 == j
  ensures a[..i] == old(a[..i])
  ensures a[j+1..] == old(a[j+1..])
  ensures a[j] == old(a[i])
  ensures a[i] == old(a[j])
  ensures multiset(a[..]) == multiset(old(a[..]))
{
   var tmp := a[i];
   a[i] := a[j];
   a[j] := tmp;  
} 


predicate sortedSeq(a:seq<int>)
{
  forall j, k :: 0 <= j < k < |a| ==> a[j] <= a[k]
}

lemma sortedSeqSubsequenceSorted(a:seq<int>, min:int, max:int)
requires 0<= min <= max <= |a|
requires sortedSeq(a)
ensures sortedSeq(a[min .. max])
{ }


method SortTransitions(initialState: StateSpace) returns (finalState: StateSpace)
modifies initialState.arr;
requires initialState.arr != null;
requires initialState.arr.Length > 0;
requires initialState.st == 0;
ensures finalState.arr !=null;
ensures sorted(finalState.arr, 0, finalState.arr.Length);
ensures multiset(initialState.arr[..]) == multiset(finalState.arr[..]);
ensures finalState.arr.Length == initialState.arr.Length;
ensures finalState.st == initialState.arr.Length;
{
  var i := 0;
  var st := initialState.st;

  while(i < initialState.arr.Length)
  decreases initialState.arr.Length -i
  decreases initialState.arr.Length - st
  invariant st - i == 0
     invariant 0 <= i <= initialState.arr.Length
     invariant sorted(initialState.arr, 0, i) 
     invariant multiset(old(initialState.arr[..])) == multiset(initialState.arr[..]);
  {
     var key := initialState.arr[i];

     var j := i - 1;

     ghost var a' := initialState.arr[..];
     assert sortedSeq(a'[0..i]);
     while(j >= 0 && key < initialState.arr[j])
     decreases j
        invariant -1 <= j <= i - 1
        invariant initialState.arr[0 .. j+1] == a'[0 .. j+1]
        invariant sorted(initialState.arr, 0, j+1);
        invariant initialState.arr[j+1] == key == a'[i];
        invariant initialState.arr[j+2 .. i+1] == a'[j+1 .. i]
        invariant sorted(initialState.arr, j+2, i+1); 
        invariant multiset(old(initialState.arr[..])) == multiset(initialState.arr[..])
        invariant forall k :: j+1 < k <= i ==> key < initialState.arr[k]                                     
     {
       ghost var a'' := initialState.arr[..];
       swap(initialState.arr, j, j+1);
       assert initialState.arr[0..j] == a''[0..j];
       assert initialState.arr[0..j] == a'[0..j];
       assert initialState.arr[j] == a''[j+1] == a'[i] == key;
       assert initialState.arr[j+2..] == a''[j+2..];
       assert initialState.arr[j+2..i+1] == a''[j+2..i+1] == a'[j+1..i];

       j := j - 1;

       sortedSeqSubsequenceSorted(a'[0..i], j+1, i);
       assert sortedSeq(a'[j+1..i]);
       assert initialState.arr[j+2 .. i+1] == a'[j+1 .. i];
       assert sortedSeq(initialState.arr[j+2..i+1]);
     }
     i := i + 1;
     st:=st+1;
  }
  var s := StateSpace(initialState.arr,st);
  return s;
}

method Main()
{
    var a := new int[5];
  a[0], a[1], a[2], a[3], a[4] := 9, 4, 6, 3, 8;
  print "Initial Array";
  var k:=0;
    while(k < a.Length) 
  decreases a.Length-k
  {
    print a[k], " "; k := k+1;
    // assert c[k] == b[k];
  }
  print "\n";
  var initialState:= rho(a);
  var terminalState := SortTransitions(initialState);
  var b:= pi(terminalState);
  assert sorted(b,0,b.Length);
  print "Final Array";
  k:=0;
    while(k < b.Length) 
  decreases b.Length-k
  {
    print b[k], " "; k := k+1;
    // assert c[k] == b[k];
  }
  print "\n";

}