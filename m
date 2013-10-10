From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/13][pull request] Intel Wired LAN Driver Updates
Date: Thu, 10 Oct 2013 15:30:40 -0400 (EDT)
Message-ID: <20131010.153040.260194679714445308.davem@davemloft.net>
References: <1381387271-29605-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755772Ab3JJTam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 15:30:42 -0400
In-Reply-To: <1381387271-29605-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed,  9 Oct 2013 23:40:58 -0700

> This series contains updates to i40e only.
> 
> Alex provides the majority of the patches against i40e, where he does
> cleanup of the Tx and RX queues and to align the code with the known
> good Tx/Rx queue code in the ixgbe driver.
> 
> Anjali provides an i40e patch to update link events to not print to
> the log until the device is administratively up.
> 
> Catherine provides a patch to update the driver version.

Pulled, thanks a lot Jeff.
