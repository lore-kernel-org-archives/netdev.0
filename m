From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: cubic update for net-2.6.22
Date: Sat, 24 Mar 2007 21:34:49 -0700 (PDT)
Message-ID: <20070324.213449.45178963.davem@davemloft.net>
References: <20070323091720.575f9162@freekitty>
	<20070323.102510.74748426.davem@davemloft.net>
	<20070323133857.5f19e4ff@freekitty>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rhee@eos.ncsu.edu, sha2@ncsu.edu, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49190
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965122AbXCYEeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Mar 2007 00:34:50 -0400
In-Reply-To: <20070323133857.5f19e4ff@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 23 Mar 2007 13:38:57 -0700

> The following update received from Injong updates TCP cubic to the latest
> version. I am running more complete tests and will have results after 4/1.
> 
> According to Injong: the new version improves on its scalability,
> fairness and stability.  So in all properties, we confirmed it shows better
> performance.
> 
> NCSU results (for 2.6.18 and 2.6.20) available:
> 	http://netsrv.csc.ncsu.edu/wiki/index.php/TCP_Testing
> 
> This version is described in a new Internet draft for CUBIC.
> 	http://www.ietf.org/internet-drafts/draft-rhee-tcp-cubic-00.txt
> 
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks Stephen.
