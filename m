From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: suggestion for routing code improvement
Date: Thu, 11 Apr 2002 18:05:19 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <15541.46143.3860.62384@robur.slu.se>
References: <15541.41833.773161.740744@robur.slu.se>
	<Pine.LNX.4.44.0204111813500.5560-100000@l>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
   Chris Friesen <cfriesen@nortelnetworks.com>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0204111813500.5560-100000@l>
List-Id: netdev.vger.kernel.org


Julian Anastasov writes:
 > >  Interesting. At what rate of new connections/s did you test?
 > 
 > 	It was on 100mbit, I already don't remember the exact tests
 > and number of clients, etc. The patch is archived ..., here it is.
 > You can try it yourself:

 > http://www.linuxvirtualserver.org/~julian/#testlvs
 > 
 > 	Sorry that it does not have flood rate limits, use QoS in
 > the flooding host :) You can try the patch with different tools,
 > of course.

 Very intesting. Well seems like I don't get out of the lab until the
 snow comes....
 
 We're testing GIGE switches now. With one Linux box with five e1000
 we can put a background load of almost 5 Gbit/s into the switch.
 And check latencies through other pair of switch ports. 

 Cheers.

						--ro
