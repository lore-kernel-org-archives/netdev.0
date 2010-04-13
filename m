From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] igb: restrict WoL for 82576 ET2 Quad Port
 Server Adapter
Date: Tue, 13 Apr 2010 03:09:02 -0700 (PDT)
Message-ID: <20100413.030902.230865560.davem@davemloft.net>
References: <20100409195029.30616.21221.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51970
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752530Ab0DMKI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 06:08:58 -0400
In-Reply-To: <20100409195029.30616.21221.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 09 Apr 2010 12:51:34 -0700

> From: Stefan Assmann <sassmann@redhat.com>
> 
> Restrict Wake-on-LAN to first port on 82576 ET2 quad port NICs, as it is
> only supported there.
> 
> Signed-off-by: Stefan Assmann <sassmann@redhat.com>
> Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
