From: "Leonid Grossman" <leonid.grossman@s2io.com>
Subject: RE: The ultimate TOE design
Date: Wed, 15 Sep 2004 22:25:48 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200409160525.i8G5PtqG009228@guinness.s2io.com>
References: <1095296279.1064.80.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>,
	<alan@lxorguk.ukuu.org.uk>, <paul@clubi.ie>, <netdev@oss.sgi.com>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S267165AbUIPF1P@vger.kernel.org>
To: <hadi@cyberus.ca>, "'Jeff Garzik'" <jgarzik@pobox.com>
In-Reply-To: <1095296279.1064.80.camel@jzny.localdomain>
List-Id: netdev.vger.kernel.org

 

> -----Original Message-----
> From: jamal [mailto:hadi@cyberus.ca] 
> Sent: Wednesday, September 15, 2004 5:58 PM
> To: Jeff Garzik
> Cc: David S. Miller; alan@lxorguk.ukuu.org.uk; paul@clubi.ie; 
> netdev@oss.sgi.com; leonid.grossman@s2io.com; 
> linux-kernel@vger.kernel.org
> Subject: Re: The ultimate TOE design
> 
> Jeff,
> You are only allowed to start a TOE thread only every six months ;->
> 
> On a serious note, I think that PCI-express (if it lives upto its
> expectation) will demolish dreams of a lot of these TOE investments.
> Our problem is NOT the CPU right now (80% idle processing 
> 450Kpps forwarding). Bus and memory distance/latency are. 

In servers, both bottlenecks are there - if you look at the cost of TCP and
filesystem processing at 10GbE, CPU is a huge problem (and will be for
foreseeable future), even for fastest 64-bit systems. 
I agree though that bus and memory are bigger issues, this is exactly the
reason for all these RDMA over Ethernet investments :-)
Anyways, did not mean to start an argument - with all the new CPU, bus and
HBA technologies coming to the market it will be another 18-24 months before
we know what works and what doesn't...
Leonid


>If 
> intel would get rid of the big conspiracy in the form of 
> chipset division and just integrate the MC like AMD is, we'll 
> be on our our way to kill TOE and a lot of the network 
> processors (like the IXP). Dang, running Linux is more 
> exciting than microcoding things to fit into a 2Kword program store. 
> 
> I rest my canadiana $.02 
> 
> cheers,
> jamal
> 
