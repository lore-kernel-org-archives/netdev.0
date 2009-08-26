From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] ixgbe: Fix isues while reporting 8259x
 backplane link capabilities
Date: Wed, 26 Aug 2009 15:38:13 -0700 (PDT)
Message-ID: <20090826.153813.177394138.davem@davemloft.net>
References: <20090825144709.15560.28811.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	mallikarjuna.chilakala@intel.com, peter.p.waskiewicz.jr@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51681
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754210AbZHZWiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 18:38:00 -0400
In-Reply-To: <20090825144709.15560.28811.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 25 Aug 2009 07:47:11 -0700

> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> 
> Fix ethtool get_settings logic to report 10G & 1G advertised and
> supported link modes in all 8259x 10G backplane connection types
> except for 82598EB BX network connection type.
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
