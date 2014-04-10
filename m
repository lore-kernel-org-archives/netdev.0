From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [patch] isdnloop: several buffer overflows
Date: Thu, 10 Apr 2014 13:16:52 +0200
Message-ID: <1397128612.21813.104938677.2F2327F5@webmail.messagingengine.com>
References: <20140408092309.GA26450@mwanda>
 <20140408.124253.1716775944053750290.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, isdn@linux-pingi.de,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:33455 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935461AbaDJLQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 07:16:53 -0400
In-Reply-To: <20140408.124253.1716775944053750290.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 8, 2014, at 18:42, David Miller wrote:
> 
> Applied and queued up for -stable, thanks.
> 
> This thing is marked broken-on-smp so the impact is very close to zero.

isdnloop is a loopback test driver for the deprecated old ISDN4Linux
subsystem.
I doubt anyone is still interested in it.

-- 
Tilman Schmidt
tilman@imap.cc
