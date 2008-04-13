From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Sun, 13 Apr 2008 20:15:20 +0200
Message-ID: <200804132015.21742.rjw@sisk.pl>
References: <20080411151821.GA32398@2ka.mipt.ru> <20080412084400.GA30259@1wt.eu> <20080412.024952.151646629.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: w@1wt.eu, johnpol@2ka.mipt.ru, lkml@rtr.ca,
	ilpo.jarvinen@helsinki.fi, jesper.juhl@gmail.com, tilman@imap.cc,
	yoshfuji@linux-ipv6.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:36491 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751972AbYDMSO5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Apr 2008 14:14:57 -0400
In-Reply-To: <20080412.024952.151646629.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday, 12 of April 2008, David Miller wrote:
> From: Willy Tarreau <w@1wt.eu>
> Date: Sat, 12 Apr 2008 10:44:00 +0200
> 
> > While it is a powerful tool, we must accept that it cannot efficiently
> > work in some circumstances, such as :
> 
> Everyone is well aware of all of this, that's why I specifically asked
> for a bisect, because I knew it would be crucial to pinpointing this
> particular bug.
> 
> And lo' and behold in 15 minutes after the bisect results were
> available it got fixed.

I can't find the fix, btw.  Can you please point me to it?

Thanks,
Rafael
