From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3] e1000e: add registers etc. printout
 code just before resetting adapters
Date: Tue, 27 Apr 2010 17:47:05 -0700 (PDT)
Message-ID: <20100427.174705.123425641.davem@davemloft.net>
References: <20100428003904.28563.2462.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	izumi.taku@jp.fujitsu.com, sanagi.koki@jp.fujitsu.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49928
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753628Ab0D1ArA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 20:47:00 -0400
In-Reply-To: <20100428003904.28563.2462.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Apr 2010 17:39:08 -0700

> From: Taku Izumi <izumi.taku@jp.fujitsu.com>
> 
> This patch adds registers (,tx/rx rings' status and so on) printout
> code just before resetting adapters. This will be helpful for detecting
> the root cause of adapters reset.
> 
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
