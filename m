From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [RFD] iptables:  mangle table obsoletes filter table
Date: Fri, 12 Oct 2007 15:01:02 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0710121449370.23981@fbirervta.pbzchgretzou.qr>
References: <200710120031.42805.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	kaber@trash.net
To: Al Boldi <a1426z@gawab.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <200710120031.42805.a1426z@gawab.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Oct 12 2007 00:31, Al Boldi wrote:
>
>With the existence of the mangle table, how useful is the filter table?

A similar discussion was back in March 2007.
http://marc.info/?l=netfilter-devel&m=117394977210823&w=2
http://marc.info/?l=netfilter-devel&m=117400063907706&w=2

in the end, my proposal was something like
http://jengelh.hopto.org/GFX0/nf_proposal2.svg
