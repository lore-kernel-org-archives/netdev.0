From: ssufficool <ssufficool@roadrunner.com>
Subject: Re: [ofa-general] Re: [PATCH RFC] RDMA/CMA: Allocate PS_TCP
	portsfrom the host TCP port space.
Date: Sun, 19 Aug 2007 21:31:40 -0700
Message-ID: <1187584300.26620.5.camel@gentoo-linux.localdomain>
References: <adatzqxwh56.fsf@cisco.com>
	<20070817.234405.66176298.davem@davemloft.net>
	<000001c7e22e$b7b90f00$29c8180a@amr.corp.intel.com>
	<20070819.002337.06589160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1379738487=="
Cc: jeff@garzik.org, netdev@vger.kernel.org, rdreier@cisco.com,
	linux-kernel@vger.kernel.org, general@lists.openfabrics.org
To: David Miller <davem@davemloft.net>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070819.002337.06589160.davem@davemloft.net>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Mime-version: 1.0
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


--===============1379738487==
Content-Type: multipart/alternative; boundary="=-OZAlozZr2EaEVpL1wUy+"


--=-OZAlozZr2EaEVpL1wUy+
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

We implemented a small office solution using Infiniband purely on a cost
per performance mark. We have a small cluster of 10 servers and for less
that 120K, all from HP. 

Pure and simple, Infiniband offers the best price per performance when
considering SAN and MPI consolidation vs F.C. + GbE. 

Not limited to top 500 HPC anymore, just those with common sense.

On Sun, 2007-08-19 at 00:23 -0700, David Miller wrote:

> From: "Sean Hefty" <sean.hefty@intel.com>
> Date: Sun, 19 Aug 2007 00:01:07 -0700
> 
> > Millions of Infiniband ports are in operation today.  Over 25% of the top 500
> > supercomputers use Infiniband.  The formation of the OpenFabrics Alliance was
> > pushed and has been continuously funded by an RDMA customer - the US National
> > Labs.  RDMA technologies are backed by Cisco, IBM, Intel, QLogic, Sun, Voltaire,
> > Mellanox, NetApp, AMD, Dell, HP, Oracle, Unisys, Emulex, Hitachi, NEC, Fujitsu,
> > LSI, SGI, Sandia, and at least two dozen other companies.  IDC expects
> > Infiniband adapter revenue to triple between 2006 and 2011, and switch revenue
> > to increase six-fold (combined revenues of 1 billion).
> 
> Scale these numbers with reality and usage.
> 
> These vendors pour in huge amounts of money into a relatively small
> number of extremely large cluster installations.  Besides the folks
> doing nuke and whole-earth simulations at some government lab, nobody
> cares.  And part of the investment is not being done wholly for smart
> economic reasons, but also largely publicity purposes.
> 
> So present your great Infiniband numbers with that being admitted up
> front, ok?
> 
> It's relevance to Linux as a general purpose operating system that
> should be "good enough" for %99 of the world is close to NIL.
> 
> People have been pouring tons of money and research into doing stupid
> things to make clusters go fast, and in such a way that make zero
> sense for general purpose operating systems, for ages.  RDMA is just
> one such example.
> 
> BTW, I find it ironic that you mention memory bandwidth as a retort,
> as Roland's favorite stateless offload devil, TSO, deals explicity
> with lowering the per-packet BUS bandwidth usage of TCP.  LRO
> offloading does likewise.
> _______________________________________________
> general mailing list
> general@lists.openfabrics.org
> http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general
> 
> To unsubscribe, please visit http://openib.org/mailman/listinfo/openib-general

--=-OZAlozZr2EaEVpL1wUy+
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 TRANSITIONAL//EN">
<HTML>
<HEAD>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; CHARSET=UTF-8">
  <META NAME="GENERATOR" CONTENT="GtkHTML/3.14.3">
</HEAD>
<BODY>
We implemented a small office solution using Infiniband purely on a cost per performance mark. We have a small cluster of 10 servers and for less that 120K, all from HP. <BR>
<BR>
Pure and simple, Infiniband offers the best price per performance when considering SAN and MPI consolidation vs F.C. + GbE. <BR>
<BR>
Not limited to top 500 HPC anymore, just those with common sense.<BR>
<BR>
On Sun, 2007-08-19 at 00:23 -0700, David Miller wrote:
<BLOCKQUOTE TYPE=CITE>
<PRE>
<FONT COLOR="#000000">From: &quot;Sean Hefty&quot; &lt;<A HREF="mailto:sean.hefty@intel.com">sean.hefty@intel.com</A>&gt;</FONT>
<FONT COLOR="#000000">Date: Sun, 19 Aug 2007 00:01:07 -0700</FONT>

<FONT COLOR="#000000">&gt; Millions of Infiniband ports are in operation today.  Over 25% of the top 500</FONT>
<FONT COLOR="#000000">&gt; supercomputers use Infiniband.  The formation of the OpenFabrics Alliance was</FONT>
<FONT COLOR="#000000">&gt; pushed and has been continuously funded by an RDMA customer - the US National</FONT>
<FONT COLOR="#000000">&gt; Labs.  RDMA technologies are backed by Cisco, IBM, Intel, QLogic, Sun, Voltaire,</FONT>
<FONT COLOR="#000000">&gt; Mellanox, NetApp, AMD, Dell, HP, Oracle, Unisys, Emulex, Hitachi, NEC, Fujitsu,</FONT>
<FONT COLOR="#000000">&gt; LSI, SGI, Sandia, and at least two dozen other companies.  IDC expects</FONT>
<FONT COLOR="#000000">&gt; Infiniband adapter revenue to triple between 2006 and 2011, and switch revenue</FONT>
<FONT COLOR="#000000">&gt; to increase six-fold (combined revenues of 1 billion).</FONT>

<FONT COLOR="#000000">Scale these numbers with reality and usage.</FONT>

<FONT COLOR="#000000">These vendors pour in huge amounts of money into a relatively small</FONT>
<FONT COLOR="#000000">number of extremely large cluster installations.  Besides the folks</FONT>
<FONT COLOR="#000000">doing nuke and whole-earth simulations at some government lab, nobody</FONT>
<FONT COLOR="#000000">cares.  And part of the investment is not being done wholly for smart</FONT>
<FONT COLOR="#000000">economic reasons, but also largely publicity purposes.</FONT>

<FONT COLOR="#000000">So present your great Infiniband numbers with that being admitted up</FONT>
<FONT COLOR="#000000">front, ok?</FONT>

<FONT COLOR="#000000">It's relevance to Linux as a general purpose operating system that</FONT>
<FONT COLOR="#000000">should be &quot;good enough&quot; for %99 of the world is close to NIL.</FONT>

<FONT COLOR="#000000">People have been pouring tons of money and research into doing stupid</FONT>
<FONT COLOR="#000000">things to make clusters go fast, and in such a way that make zero</FONT>
<FONT COLOR="#000000">sense for general purpose operating systems, for ages.  RDMA is just</FONT>
<FONT COLOR="#000000">one such example.</FONT>

<FONT COLOR="#000000">BTW, I find it ironic that you mention memory bandwidth as a retort,</FONT>
<FONT COLOR="#000000">as Roland's favorite stateless offload devil, TSO, deals explicity</FONT>
<FONT COLOR="#000000">with lowering the per-packet BUS bandwidth usage of TCP.  LRO</FONT>
<FONT COLOR="#000000">offloading does likewise.</FONT>
<FONT COLOR="#000000">_______________________________________________</FONT>
<FONT COLOR="#000000">general mailing list</FONT>
<FONT COLOR="#000000"><A HREF="mailto:general@lists.openfabrics.org">general@lists.openfabrics.org</A></FONT>
<FONT COLOR="#000000"><A HREF="http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general">http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general</A></FONT>

<FONT COLOR="#000000">To unsubscribe, please visit <A HREF="http://openib.org/mailman/listinfo/openib-general">http://openib.org/mailman/listinfo/openib-general</A></FONT>
</PRE>
</BLOCKQUOTE>
</BODY>
</HTML>

--=-OZAlozZr2EaEVpL1wUy+--


--===============1379738487==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1379738487==--
