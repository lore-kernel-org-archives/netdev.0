From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: FW: Submission for S2io 10GbE driver
Date: Sat, 24 Jan 2004 11:52:16 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <002401c3e2b3$94038d70$0400a8c0@S2IOtech.com>
References: <1074966855.1732.8.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <hadi@cyberus.ca>, "'Andi Kleen'" <ak@suse.de>
In-Reply-To: <1074966855.1732.8.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Leonid,
> 
> What would also be interesting to see is a packet that never
> leaves the kernel such is in forwarding. If theres a way you 
> can stash two of those cards in a box and just have them 
> forward packets coming in from one to another - would be nice 
> to see the numbers with varying packet size example { 
> 64,256,512,1518, 4K, 9K} 
> 
> cheers,
> jamal


Hi Jamal, 
Are you suggesting to run a benchmark between two back-to-back hosts,
and then run the same benchmark between the two hosts via a third box
(with two 10GbE cards) that would just forward traffic, and compare the
results? 
Or you had a different setup in mind? 
Not sure what the application for something like this would be (I think
10GbE will be mainly deployed in a datacenter for a while), but we can
probably run something like that and get the numbers; I'll let you know.

Thanks, Leonid
