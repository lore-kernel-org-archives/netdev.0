From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: HTB - very bad precision? HFSC works fine! 2.6.28
Date: Thu, 8 Jan 2009 10:40:32 +0000
Message-ID: <20090108104032.GA5493@ff.dom.local>
References: <20090108092720.GC4496@ff.dom.local> <200901081134.41467.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f31.google.com ([209.85.219.31]:42046 "EHLO
	mail-ew0-f31.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754633AbZAHKki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 05:40:38 -0500
Received: by ewy12 with SMTP id 12so3104115ewy.13
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2009 02:40:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200901081134.41467.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 08, 2009 at 11:34:41AM +0200, Denys Fedoryschenko wrote:
> I will check all this things, as soon as traffic reach peak (after 6 hours i 
> think).
...
> On Thursday 08 January 2009 11:27:20 Jarek Poplawski wrote:
...
> > tested? Could you do a few snapshots with: tc -s qdisc show dev $DEV

I forgot to mention: tc -s class show dev $DEV
as well.

Thanks,
Jarek P.
