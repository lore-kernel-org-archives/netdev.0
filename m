From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Sun, 5 Oct 2008 22:40:13 +0200
Message-ID: <20081005204013.GB2526@ami.dom.local>
References: <20081002194845.GB2664@ami.dom.local> <20081003073418.GA5235@ff.dom.local> <20081003074351.GB5235@ff.dom.local> <1223145027.23358.20.camel@f6bvp-5> <20081004191114.GA15152@ami.dom.local> <20081004200939.GB15152@ami.dom.local> <1223231469.18094.10.camel@f6bvp-5>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>
To: "Bernard, f6bvp" <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:38405 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755053AbYJEUkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2008 16:40:05 -0400
Received: by nf-out-0910.google.com with SMTP id d3so918146nfc.21
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2008 13:40:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1223231469.18094.10.camel@f6bvp-5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 05, 2008 at 08:31:09PM +0200, Bernard, f6bvp wrote:
> Here are a few interesting data captured via netconsole from
> kernel-2.6.27-rc7 without af_netrom patch #4.
> 
...
> AX25_DBG: c67ef160, c5189aa8, 6, 5, 0
...
> AX25_DBG: c67eed48, c5186008, 6, 5, 0

So, it looks like this patch could make some change, but I'd like to be
sure again: with or without David's patch?

Thanks,
Jarek P.
