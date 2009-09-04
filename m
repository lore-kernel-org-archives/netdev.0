From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 00/11] enic: updates
Date: Thu, 03 Sep 2009 20:23:26 -0700 (PDT)
Message-ID: <20090903.202326.216512920.davem@davemloft.net>
References: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50808
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932619AbZIDDXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:23:11 -0400
In-Reply-To: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Thu, 03 Sep 2009 20:01:43 -0700

> The following series implements updates to the enic netdev driver for
> Cisco's 10G Ethernet NIC:
> 
>       01 enic: add support for multiple BARs
>       02 enic: workaround A0 erratum
>       03 enic: bug fix: split TSO fragments larger than 16K into
>          multiple descs
>       04 enic: use netdev_alloc_skb
>       05 enic: bug fix: protect fw call i/f with spinlock
>       06 enic: bug fix: included MAC drops in rx_dropped netstat
>       07 enic: provision for multiple Rx/Tx queues; prepare for RSS support
>       08 enic: bug fix: enable VLAN filtering
>       09 enic: changes to driver/firmware interface
>       10 enic: bug fix: check for zero port MTU before posting warning
>       11 enic: organize device initialization/deinit into separate functions
> 
> Please apply.
> 
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>

Looks good, all aplied, thanks!
