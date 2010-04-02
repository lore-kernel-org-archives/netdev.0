From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] igb: restrict WoL for 82576 ET2 Quad Port
 Server Adapter
Date: Thu, 01 Apr 2010 19:34:35 -0700 (PDT)
Message-ID: <20100401.193435.223373423.davem@davemloft.net>
References: <4BB4D13C.8030303@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com,
	jeffrey.t.kirsher@intel.com
To: sassmann@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39362
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754758Ab0DBCee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 22:34:34 -0400
In-Reply-To: <4BB4D13C.8030303@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@redhat.com>
Date: Thu, 01 Apr 2010 19:00:44 +0200

> From: Stefan Assmann <sassmann@redhat.com>
> 
> Restrict Wake-on-LAN to first port on 82576 ET2 quad port NICs, as it is
> only supported there.
> 
> Signed-off-by: Stefan Assmann <sassmann@redhat.com>

Intel folks I assume you will suck this in and resubmit to
me?

Thanks.
