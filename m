From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/5] cpsw interrupt pacing and get/set phy setting
 implementation
Date: Wed, 13 Mar 2013 04:39:09 -0400 (EDT)
Message-ID: <20130313.043909.1985225524093989490.davem@davemloft.net>
References: <1363079798-18147-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-omap@vger.kernel.org, b-cousson@ti.com, paul@pwsan.com
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40008 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753102Ab3CMIi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 04:38:58 -0400
In-Reply-To: <1363079798-18147-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Tue, 12 Mar 2013 14:46:33 +0530

> This patch serires implements the following features in CPSW driver
> * get/set phy link settings
> * interrupt pacing
> * get phy id via ioctl cmd SIOCGMIIPHY
> 
> Changes from initial version
> * Made active-slave common for cpts, ethtool and SIOCGMIIPHY ioctl
> * Cleaned CPSW DT binding documentation by seperating slave nodes
>   under sub-section
> * implemented get phy id via ioctl cmd SIOCGMIIPHY

Series applied, thanks.
