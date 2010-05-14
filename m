From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/3] ixgbe: Refactor common code between
 82598 & 82599 to accommodate new hardware
Date: Thu, 13 May 2010 21:09:28 -0700 (PDT)
Message-ID: <20100513.210928.27810036.davem@davemloft.net>
References: <20100514033233.30716.30144.stgit@localhost.localdomain>
	<20100514033339.30716.24026.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43834
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751048Ab0ENEJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 00:09:20 -0400
In-Reply-To: <20100514033339.30716.24026.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 13 May 2010 20:33:41 -0700

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> Some of the following MAC functions are moved from 82598 & 82599 specific
> hardware files to common.[ch] to accommodate new silicon changes. Also
> fixed some white space issues
>  * get_san_mac_addr, check_link, set_vmdq, clear_vmdq, clear_vfta,
>  * set_vfta, fc_enable, init_uta_tables
> 
> Signed-off-by:  Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
