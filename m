From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2.6.29] cxgb3 - manage private iSCSI IP address
Date: Thu, 18 Dec 2008 22:56:32 -0800 (PST)
Message-ID: <20081218.225632.113687804.davem@davemloft.net>
References: <200812190243.mBJ2hPZY008757@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	michaelc@cs.wisc.edu, James.Bottomley@HansenPartnership.com,
	divy@chelsio.com, swise@opengridcomputing.com
To: kxie@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35081
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751852AbYLSG4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 01:56:31 -0500
In-Reply-To: <200812190243.mBJ2hPZY008757@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karen Xie <kxie@chelsio.com>
Date: Thu, 18 Dec 2008 18:43:25 -0800

> [PATCH v3 2.6.29] cxgb3 - manage private iSCSI IP address
> 
> The accelerated iSCSI traffic could use a private IP address unknown to the OS:
> - The IP address is required in both drivers to manage ARP requests and connection set up.
> - Added an control call to retrieve the ip address.
> - Reply to ARP requests dedicated to the private IP address.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> Signed-off-by: Karen Xie <kxie@chelsio.com>

Patch applied, thank you.
