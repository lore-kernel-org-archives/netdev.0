From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/4] e1000e: Remove unnessary log message
Date: Thu, 06 May 2010 00:19:47 -0700 (PDT)
Message-ID: <20100506.001947.233691833.davem@davemloft.net>
References: <20100506000221.8042.64794.stgit@localhost.localdomain>
	<20100506000309.8042.9387.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, therbert@google.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47764
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753142Ab0EFHTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 May 2010 03:19:40 -0400
In-Reply-To: <20100506000309.8042.9387.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 05 May 2010 17:03:11 -0700

> From: Tom Herbert <therbert@google.com>
> 
> Remove e_info message printed whenever TSO is enabled or disabled.
> This is not very useful and just clutters dmesg.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> Acked-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
