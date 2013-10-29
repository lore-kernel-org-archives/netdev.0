From: Luka Perkov <luka@openwrt.org>
Subject: Re: [PATCH] ethernet/arc/arc_emac: drop redundant mac address check
Date: Tue, 29 Oct 2013 10:10:28 +0100
Message-ID: <20131029091028.GA18147@w500.lan>
References: <1383010340-26445-1-git-send-email-luka@openwrt.org>
 <20131028.234842.1406231268962965513.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, abrodkin@synopsys.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:41815 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752394Ab3J2JKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 05:10:32 -0400
Content-Disposition: inline
In-Reply-To: <20131028.234842.1406231268962965513.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Mon, Oct 28, 2013 at 11:48:42PM -0400, David Miller wrote:
> I've seen you use three inconsistent Subject prefixes here, pick a scheme
> and stick to it please!
> 
> First patch was:
> 
> netdev: ${driver_name}:
> 
> Second patch was:
> 
> net: ${driver_name}:
> 
> Third patch was:
> 
> patch/to/driver/directory:

True. I have sent it that way because I've followed the commit
schematics of each driver individually.

> This is really not acceptable.  Just using "${driver_name}: " is good
> enough.

It's not a problem to resend them... But I'm wondering should this be
squashed into one patch?

Luka
