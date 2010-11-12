From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 v2 1/3] vlan: Add function to retrieve
 EtherType from vlan packets.
Date: Fri, 12 Nov 2010 12:24:19 -0800 (PST)
Message-ID: <20101112.122419.39169340.davem@davemloft.net>
References: <1289519279-20641-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hzheng@nicira.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47669
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932269Ab0KLUX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Nov 2010 15:23:56 -0500
In-Reply-To: <1289519279-20641-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Thu, 11 Nov 2010 15:47:57 -0800

> From: Hao Zheng <hzheng@nicira.com>
> 
> Depending on how a packet is vlan tagged (i.e. hardware accelerated or
> not), the encapsulated protocol is stored in different locations.  This
> provides a consistent method of accessing that protocol, which is needed
> by drivers, security checks, etc.
> 
> Signed-off-by: Hao Zheng <hzheng@nicira.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
