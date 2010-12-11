From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] enic: Move enic port profile handling
 code to a new 802.1Qbh provisioning info type
Date: Fri, 10 Dec 2010 16:22:23 -0800 (PST)
Message-ID: <20101210.162223.216771509.davem@davemloft.net>
References: <20101210220233.5010.37181.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roprabhu@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34758
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757234Ab0LKAVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:21:55 -0500
In-Reply-To: <20101210220233.5010.37181.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>
Date: Fri, 10 Dec 2010 14:02:33 -0800

> From: Roopa Prabhu <roprabhu@cisco.com>
> 
> 
> 
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>
> Signed-off-by: Christian Benvenuti <benve@cisco.com>

Commit message could explain why you're doing this, but I'll
apply this as it is pretty simple.
