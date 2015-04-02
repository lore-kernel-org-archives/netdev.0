From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/18] Mellanox mlx4 driver updates
Date: Thu, 02 Apr 2015 16:25:45 -0400 (EDT)
Message-ID: <20150402.162545.2194540262764717640.davem@davemloft.net>
References: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idos@mellanox.com, amirv@mellanox.com,
	talal@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41121 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750942AbbDBUZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 16:25:48 -0400
In-Reply-To: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu,  2 Apr 2015 16:31:05 +0300

> The main feature added by this series are Ido's changes to support 
> Granular QoS for VFs, where for the time being only max rate is supported.
> 
> Muhammad added support for setting rx-fcs and rx-all through ethtool, 
> and Ido did the interface identify work.
> 
> Last, add Ido as a maintainer for the mlx4 Ethernet driver!
> 
> Some of next week is the Passover holiday here and I will be 
> mostly OOO. If needed (...) Ido or Amir will send V1 and such.
> 
> Rebased against net-next commit 033f46b "crypto: algif - 
> explicitly mark end of data".

Series applied, thanks.
