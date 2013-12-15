From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/2] i40e: fix null dereference
Date: Sat, 14 Dec 2013 23:00:14 -0500 (EST)
Message-ID: <20131214.230014.311930387892009434.davem@davemloft.net>
References: <1387020406-7964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753882Ab3LOEAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 23:00:16 -0500
In-Reply-To: <1387020406-7964-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 14 Dec 2013 03:26:45 -0800

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> If the vsi->tx_rings structure is NULL we don't want to panic.
> 
> Change-Id: Ic694f043701738c434e8ebe0caf0673f4410dc10
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
