From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] netfilter: netfilter update
Date: Wed, 09 Feb 2011 12:39:11 -0800 (PST)
Message-ID: <20110209.123911.226781265.davem@davemloft.net>
References: <1297262027-26237-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33605
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751364Ab1BIUig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Feb 2011 15:38:36 -0500
In-Reply-To: <1297262027-26237-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kaber@trash.net
Date: Wed,  9 Feb 2011 15:33:45 +0100

> following are two IPVS patches for net-next-2.6, fixing:
> 
> - use of an incorrect lock in the SCTP module, from Simon
> 
> - a precedence bug in ip_vs_sync_switch_mode(), from Dan Carpenter
> 
> Please pull from:
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git master

Pulled, thanks Patrick.
