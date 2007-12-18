From: Glen Turner <gdt@gdt.id.au>
Subject: Re: Packet per Second
Date: Tue, 18 Dec 2007 10:56:20 +1030
Message-ID: <1197937580.6111.31.camel@andromache>
References: <nemoFri121407105527@flis.man.torun.pl>
	 <1197671513.5973.10.camel@andromache>
	 <nemoMon121707091528@flis.man.torun.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Fl=E1vio?= Pires <flavio.defreitas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:59048 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759578AbXLRA1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 19:27:25 -0500
In-Reply-To: <nemoMon121707091528@flis.man.torun.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Apologies for off-topic]

On Mon, 2007-12-17 at 11:18 +0000, Fl=C3=A1vio Pires wrote:
> I alread though about something like this. But, isn`t NetFlow just fo=
r
> Cisco IOS ?

NetFlow is a trade mark of Cisco Systems Inc (USA).

Packets in the identical format used by NetFlow are produced by
a wide range of networking equipment, including a number of
Linux tools.  I've seen the Linux tools used in customer
networks but I've never evaluated them myself, which is why
I'm didn't make a recommendation of a particular tool for the
sampler.

Because of the trade mark you'll often find NetFlow traffic
samplers under names other than NetFlow (eg, Juniper uses
"cflowd" as a synonym for NetFlow).  There is one exception:
sFlow is *not* identical to the NetFlow format.

If you want more information on ISP accounting tools, the NANOG
list is a more suitable forum.  The Cisco-NSP and Juniper-NSP
lists often host useful discussions too.  The archives of all
these lists are online.

Best wishes, Glen

--=20
Glen Turner   <http://www.gdt.id.au/~gdt/>
Tel: 0416 295 857 or +61 416 295 857

