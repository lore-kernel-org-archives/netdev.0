From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 4/4] ixgbe: Not allow 8259x unsupported wol
 options change from ethtool
Date: Fri, 03 Jul 2009 19:12:28 -0700 (PDT)
Message-ID: <20090703.191228.26001941.davem@davemloft.net>
References: <20090702225012.22746.57218.stgit@localhost.localdomain>
	<20090702225110.22746.42383.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36299
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758213AbZGDCMV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 22:12:21 -0400
In-Reply-To: <20090702225110.22746.42383.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 02 Jul 2009 15:51:10 -0700

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> Wake-on-lan is currently only supported by 82599 KX4 devices, in all
> other cases return a proper value from ixgbe_wol_exclusion function call.
> Otherwise from ethtool we will be able to change wol options of
> unsupported 8259x devices.
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---

Applied.
