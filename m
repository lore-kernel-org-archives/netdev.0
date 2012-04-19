From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] iwlwifi: Remove inconsistent and redundant declaration
Date: Thu, 19 Apr 2012 16:56:50 -0400 (EDT)
Message-ID: <20120419.165650.1648773539695663790.davem@davemloft.net>
References: <1334868398-7095-1-git-send-email-wey-yi.w.guy@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.spinadel@intel.com
To: wey-yi.w.guy@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755782Ab2DSU4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 16:56:53 -0400
In-Reply-To: <1334868398-7095-1-git-send-email-wey-yi.w.guy@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wey-Yi Guy <wey-yi.w.guy@intel.com>
Date: Thu, 19 Apr 2012 13:46:38 -0700

> From: David Spinadel <david.spinadel@intel.com>
> 
> Remove declaration of iwl_alloc_traffic_mem from iwl-agn.h,
> from methods that was exposed to support MVM.
> 
> MVM doesn't have to use this declaration.
> 
> CC: netdev@vger.kernel.org
> Signed-off-by: David Spinadel <david.spinadel@intel.com>
> Signed-off-by: Wey-Yi Guy <wey-yi.w.guy@intel.com>

Applied.
