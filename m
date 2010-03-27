From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000e: Use pr_<level> and netdev_<level>
Date: Fri, 26 Mar 2010 21:05:55 -0700 (PDT)
Message-ID: <20100326.210555.251082007.davem@davemloft.net>
References: <20100324225529.7104.17189.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, joe@perches.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37280
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750742Ab0C0EFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 00:05:31 -0400
In-Reply-To: <20100324225529.7104.17189.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 24 Mar 2010 15:55:30 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> As an alternative to a quite large patch previously submitted by Joe
> Perches to make use of kernel logging API, this patch is much less
> intrusive.
> 
> Convert e_<level> to netdev_<level>
> Use #define pr_fmt
> Convert a few printks to pr_<level>
> 
> Cc: Joe Perches <joe@perches.com>
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied to net-next-2.6
