From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000e: change logical negate to bitwise
Date: Thu, 03 Jun 2010 03:30:02 -0700 (PDT)
Message-ID: <20100603.033002.107135186.davem@davemloft.net>
References: <20100602234314.13472.35872.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, error27@gmail.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50312
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933843Ab0FCK3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:29:53 -0400
In-Reply-To: <20100602234314.13472.35872.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 02 Jun 2010 16:43:15 -0700

> From: Dan Carpenter <error27@gmail.com>
> 
> The bitwise negate is intended here.  With the logical negate the
> condition is always false.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> Acked-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
