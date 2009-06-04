From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] removal of forcedeth device ids
Date: Thu, 04 Jun 2009 02:06:18 -0700 (PDT)
Message-ID: <20090604.020618.146585165.davem@davemloft.net>
References: <4A271DE9.1090306@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, akpm@osdl.org, netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44966
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753941AbZFDJGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 05:06:17 -0400
In-Reply-To: <4A271DE9.1090306@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>
Date: Wed, 03 Jun 2009 21:05:45 -0400

> This patch removes the forcedeth device ids from pci_ids.h
> 
> The forcedeth driver uses the device id constants directly in its
> source file.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

Applied to net-next-2.6

