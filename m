From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Linux SMP on 2.4.18-3
Date: Wed, 30 Oct 2002 20:03:29 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15808.11521.25342.659187@robur.slu.se>
References: <Pine.GSO.4.30.0210280741020.9849-100000@shell.cyberus.ca>
	<Pine.LNX.4.33L0.0210281020180.28869-100000@fast2.cs.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Cheng Jin <chengjin@cs.caltech.edu>
In-Reply-To: <Pine.LNX.4.33L0.0210281020180.28869-100000@fast2.cs.caltech.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Cheng Jin writes:

 > Out of curiosity, what is the maximum send rate (pps) under Linux
 > 2.4.18-3?  I read in the paper that sending across two Intel Gbe with one
 > CPU gets up to 36o Kpps.

 Yes forwarding performance... 

 A good chip/driver can itself do a lot more. I have seen very decent numbers
 with e1000, tg3 and dl2k. For FE tulip has been a top performer for long 
 time but  I also now see 144 kpps from my laptop w. 3c59x driver.

 Cheers.
						--ro
