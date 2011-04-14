From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bridge: reset IPCB in br_parse_ip_options
Date: Wed, 13 Apr 2011 17:03:51 -0700
Message-ID: <20110413170351.078cfa2f@nehalam>
References: <4DA522B2.90200@scotdoyle.com>
	<4DA5BCF7.9020606@scotdoyle.com>
	<1302708487.3725.0.camel@edumazet-laptop>
	<20110413.144812.116375845.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, lkml@scotdoyle.com,
	shimoda.hiroaki@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43342 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750748Ab1DNAD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 20:03:57 -0400
In-Reply-To: <20110413.144812.116375845.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Apr 2011 14:48:12 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 13 Apr 2011 17:28:07 +0200
> 
> > Dont worry, Stephen or me will send it asap.
> 
> I'm looking forward to it :)

You applied the clear of ipcb already.
