From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] igb: fix handling of mailbox collisions
 between PF/VF
Date: Fri, 11 Dec 2009 22:58:23 -0800 (PST)
Message-ID: <20091211.225823.260104931.davem@davemloft.net>
References: <20091212034033.10674.67054.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42109
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750699AbZLLG6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 01:58:18 -0500
In-Reply-To: <20091212034033.10674.67054.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 11 Dec 2009 19:40:57 -0800

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This patch changes the handling of collisions between the use of the PF/VF
> sides of the mailbox.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
