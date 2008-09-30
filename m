From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Tue, 30 Sep 2008 10:10:30 +0000
Message-ID: <20080930101030.GA6290@ff.dom.local>
References: <48DF7D51.1010507@free.fr> <20080929123036.GA16954@ff.dom.local> <48E1F417.7080304@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>
To: Bernard Pidoux F6BVP <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.190]:43166 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752532AbYI3KKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 06:10:38 -0400
Received: by mu-out-0910.google.com with SMTP id g7so2103066muf.1
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2008 03:10:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48E1F417.7080304@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2008 at 11:40:39AM +0200, Bernard Pidoux F6BVP wrote:
> Hi Jarek,
Hi Bernard,

>
> Yes this is a vanilla kernel, which makes it interesting to debug.
> I forgot to Cc: Ralf and put it now on copy of this message.
> Thank you for the patch I applied.
> Collected data includes both events I already reported, first the  
> inconsistent lock state,

I guess this netconsole is on ne2k_pci/8390 driver?

> second the kernel bug followed by a kernel  
> panic. The second event only occured after I intentionally started,  
> after a while, FPAC application using rose protocole .

BTW, the main question: is this second bug something new or happens
with previous kernels (especially 2.6.26) too?

Thanks,
Jarek P.
