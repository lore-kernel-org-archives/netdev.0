From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ixgbe: allow tx of pre-formatted vlan tagged
 packets
Date: Tue, 15 Dec 2009 21:14:16 -0800 (PST)
Message-ID: <20091215.211416.183030058.davem@davemloft.net>
References: <20091215230030.26068.26462.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, gshetty@riverbed.com,
	ajones@riverbed.com, mallikarjuna.chilakala@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39283
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752304AbZLPFOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 00:14:15 -0500
In-Reply-To: <20091215230030.26068.26462.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 15 Dec 2009 15:00:31 -0800

> From: Gurucharan Shetty <gshetty@riverbed.com>
> 
> When the 82598 is fed 802.1q packets, it chokes with
> an error of the form:
> 
> ixgbe: eth0: ixgbe_tx_csum: partial checksum but proto=81!
 ...
> Signed-off-by: Gurucharan Shetty <gshetty@riverbed.com>
> Signed-off-by: Arthur Jones <ajones@riverbed.com>
> Acked-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
