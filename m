From: "Sergio Luis" <sergio@uece.br>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Sun, 13 Apr 2008 15:51:13 -0300
Message-ID: <ce0170d90804131151ia99147bv9ad12e625191be5e@mail.gmail.com>
References: <20080411151821.GA32398@2ka.mipt.ru>
	 <20080412084400.GA30259@1wt.eu>
	 <20080412.024952.151646629.davem@davemloft.net>
	 <200804132015.21742.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, w@1wt.eu,
	johnpol@2ka.mipt.ru, lkml@rtr.ca, ilpo.jarvinen@helsinki.fi,
	jesper.juhl@gmail.com, tilman@imap.cc, yoshfuji@linux-ipv6.org,
	jeff@garzik.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:27980 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752615AbYDMSvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 14:51:15 -0400
Received: by fk-out-0910.google.com with SMTP id 19so1330789fkr.5
        for <netdev@vger.kernel.org>; Sun, 13 Apr 2008 11:51:13 -0700 (PDT)
In-Reply-To: <200804132015.21742.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 13, 2008 at 3:15 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> On Saturday, 12 of April 2008, David Miller wrote:
>  > From: Willy Tarreau <w@1wt.eu>
>  > Date: Sat, 12 Apr 2008 10:44:00 +0200
>  >
>  > > While it is a powerful tool, we must accept that it cannot efficiently
>  > > work in some circumstances, such as :
>  >
>  > Everyone is well aware of all of this, that's why I specifically asked
>  > for a bisect, because I knew it would be crucial to pinpointing this
>  > particular bug.
>  >
>  > And lo' and behold in 15 minutes after the bisect results were
>  > available it got fixed.
>
>  I can't find the fix, btw.  Can you please point me to it?

there you go
http://lkml.org/lkml/2008/4/10/409
http://lkml.org/lkml/2008/4/10/410

>
>  Thanks,
>  Rafael

  -sergio
