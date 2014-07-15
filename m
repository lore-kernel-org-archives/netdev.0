From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] amd-xgbe: Remove baseT workaround for
 fixed speeds
Date: Tue, 15 Jul 2014 16:31:17 -0700 (PDT)
Message-ID: <20140715.163117.1285144297464902894.davem@davemloft.net>
References: <20140714190540.23626.62720.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45604 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760284AbaGOXbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 19:31:18 -0400
In-Reply-To: <20140714190540.23626.62720.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Mon, 14 Jul 2014 14:05:40 -0500

> The following series expands the speed/duplex settings array in phy.c
> to support additional media types. With this expansion the workaround
> in the amd-xgbe driver to set/remove baseT media types based on whether
> auto negotiation is enabled can be removed.
> 
> This patch series is based on net-next.

Series applied, thanks Tom.
