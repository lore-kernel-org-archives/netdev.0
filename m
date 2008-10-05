From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Sun, 5 Oct 2008 23:09:31 +0200
Message-ID: <20081005210931.GC2526@ami.dom.local>
References: <20081002194845.GB2664@ami.dom.local> <20081003073418.GA5235@ff.dom.local> <20081003074351.GB5235@ff.dom.local> <1223145027.23358.20.camel@f6bvp-5> <20081004191114.GA15152@ami.dom.local> <20081004200939.GB15152@ami.dom.local> <1223221212.18094.4.camel@f6bvp-5> <20081005203345.GA2526@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>
To: "Bernard, f6bvp" <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:40283 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754642AbYJEVJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 17:09:10 -0400
Received: by nf-out-0910.google.com with SMTP id d3so920431nfc.21
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2008 14:09:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081005203345.GA2526@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 05, 2008 at 10:33:45PM +0200, Jarek Poplawski wrote:
> On Sun, Oct 05, 2008 at 05:40:12PM +0200, Bernard, f6bvp wrote:
> > With kernel-2.6.27-rc7 and ypur patches including netrom one I observed
> > three events via netconsole.
> > I think that they were triggered by NetRom activity I exercized on
> > purpose.
> > See attached documents.
> 
> Bernard, do you mean exactly "With kernel-2.6.27-rc7 and ypur patches
> including netrom" or this all and David's patch reverted?

More precisely: I'd like to finish the main problem (oops) in this
thread before trying possibly new things in NetRom etc., so it would
be nice if you could acknowledge to David that reverting his patch
fixes this for sure. Additionally it would be nice to check this
Tihomir Heidelberg's fix as an alternative.

Jarek P.
