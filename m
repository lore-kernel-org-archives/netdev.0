From: Al Boldi <a1426z@gawab.com>
Subject: Re: [RFD] iptables:  mangle table obsoletes filter table
Date: Sat, 13 Oct 2007 01:56:54 +0300
Message-ID: <200710130156.54050.a1426z@gawab.com>
References: <200710120031.42805.a1426z@gawab.com> <Pine.LNX.4.64.0710121533360.23981@fbirervta.pbzchgretzou.qr> <470F7B4B.2010609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <470F7B4B.2010609@trash.net>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Jan Engelhardt wrote:
> > On Oct 12 2007 16:30, Al Boldi wrote:
> >>>>With the existence of the mangle table, how useful is the filter
> >>>> table?
> >>>
> >>>A similar discussion was back in March 2007.
> >>>http://marc.info/?l=netfilter-devel&m=117394977210823&w=2
> >>>http://marc.info/?l=netfilter-devel&m=117400063907706&w=2
> >>>
> >>>in the end, my proposal was something like
> >>>http://jengelh.hopto.org/GFX0/nf_proposal2.svg
> >>
> >>Any chance you could publish this as something readable like text/html?
> >
> > Like, image/png?
> > http://jengelh.hopto.org/GFX0/nf_proposal2.png
>
> The netlink based iptables successor I'm currently working on allows to
> dynamically create tables with user-specified priorities and "built-in"
> chains. The only built-in tables will be those that need extra
> processing (mangle/nat). So it should be possible to set up tables
> basically any way you desire.

Wow!  How soon can we expect this to surface on mainline?


Thanks a lot!

--
Al
