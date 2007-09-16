From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix the prototype of call_netdevice_notifiers
Date: Sun, 16 Sep 2007 15:33:57 -0700 (PDT)
Message-ID: <20070916.153357.52174620.davem@davemloft.net>
References: <m1y7fa5zg6.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:51637
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753266AbXIPWeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 18:34:09 -0400
In-Reply-To: <m1y7fa5zg6.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 13 Sep 2007 09:59:05 -0600

> 
> This replaces the void * parameter with a struct net_device * which
> is what is actually required.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied to net-2.6.24, thanks Eric.
