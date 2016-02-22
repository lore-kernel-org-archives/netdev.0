From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by
 default
Date: Sun, 21 Feb 2016 22:06:10 -0500 (EST)
Message-ID: <20160221.220610.2156659433965765266.davem@davemloft.net>
References: <20160219191806.15687.37621.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com
To: aduyck@mirantis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43004 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752928AbcBVDGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2016 22:06:12 -0500
In-Reply-To: <20160219191806.15687.37621.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <aduyck@mirantis.com>
Date: Fri, 19 Feb 2016 11:26:17 -0800

> This patch series makes it so that we enable the outer Tx checksum
> for IPv4 tunnels by default.

Series applied, thanks Alex.
