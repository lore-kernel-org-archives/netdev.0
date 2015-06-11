From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/18][pull request] Intel Wired LAN Driver Updates
 2015-06-09
Date: Wed, 10 Jun 2015 22:14:31 -0700 (PDT)
Message-ID: <20150610.221431.1687697836196734479.davem@davemloft.net>
References: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57914 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbbFKFOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 01:14:32 -0400
In-Reply-To: <1433898629-76729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  9 Jun 2015 18:10:11 -0700

> This series contains updates to ixgbe only.
> 
> The series adds additional support for x550 support, such as WoL and
> auto-negotiation of flow control.  Adds new PHY support (external PHY)
> for x550, as well as the new methods/functions needed to support the new
> PHY's.  Fixed a bug found in code inspection, where a check was missed
> when clearing counters for x550.  Also fixed the init code flow for copper
> x550 devices.

Pulled, thanks a lot Jeff.
