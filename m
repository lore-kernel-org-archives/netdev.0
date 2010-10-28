From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] igbvf: fix panic on load
Date: Thu, 28 Oct 2010 10:20:03 -0700 (PDT)
Message-ID: <20101028.102003.104053837.davem@davemloft.net>
References: <20101028105951.27748.36868.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	emil.s.tantilov@intel.com, greg.v.rose@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45545
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933943Ab0J1RTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 13:19:39 -0400
In-Reply-To: <20101028105951.27748.36868.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 28 Oct 2010 03:59:51 -0700

> From: Emil Tantilov <emil.s.tantilov@intel.com>
> 
> Introduced by commit:e6484930d7c73d324bccda7d43d131088da697b9
> net: allocate tx queues in register_netdevice
> 
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Acked-by: Greg Rose <greg.v.rose@intel.com>
> Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
