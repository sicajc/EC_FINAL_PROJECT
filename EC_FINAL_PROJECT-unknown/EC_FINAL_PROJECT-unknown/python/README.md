
1.change into non-self_adaptive mutate(INT8)<br />
2.change crossoverFraction into INT8<br />
3.three kinds of randam number generation need to do<br />
<1> self.uniprng.randint(1, 255)<br />
<2> self.uniprng.randint(0, self.nItems-1)<br />
<3> self.uniprng.shuffle<br />
    
