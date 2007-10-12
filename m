From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [RFD] iptables:  mangle table obsoletes filter table
Date: Fri, 12 Oct 2007 16:02:36 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0710121553450.23981@fbirervta.pbzchgretzou.qr>
References: <200710120031.42805.a1426z@gawab.com>
 <Pine.LNX.4.64.0710121449370.23981@fbirervta.pbzchgretzou.qr>
 <200710121630.29151.a1426z@gawab.com> <Pine.LNX.4.64.0710121533360.23981@fbirervta.pbzchgretzou.qr>
 <470F7B4B.2010609@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Al Boldi <a1426z@gawab.com>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757309AbXJLOCz@vger.kernel.org>
In-Reply-To: <470F7B4B.2010609@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Oct 12 2007 15:48, Patrick McHardy wrote:
>
>The netlink based iptables successor I'm currently working on allows to
>dynamically create tables with user-specified priorities and "built-in"
>chains. The only built-in tables will be those that need extra
>processing (mangle/nat). So it should be possible to set up tables
>basically any way you desire.

Will ebtables move a bit closer to iptables?
