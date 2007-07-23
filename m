From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 1/2] forcedeth: new device ids in pci_ids.h
Date: Mon, 23 Jul 2007 22:23:20 +0100
Message-ID: <20070723222320.33591cda@oldman>
References: <46A3F9A3.10508@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:42341 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752590AbXGWVX4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2007 17:23:56 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1ID5Nh-0001nR-4Z
	for netdev@vger.kernel.org; Mon, 23 Jul 2007 23:23:53 +0200
Received: from 87.192.216.40 ([87.192.216.40])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 23:23:53 +0200
Received: from shemminger by 87.192.216.40 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 23:23:53 +0200
In-Reply-To: <46A3F9A3.10508@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 22 Jul 2007 20:43:15 -0400
Ayaz Abdulla <aabdulla@nvidia.com> wrote:

> This patch contains new device ids for MCP73 chipset.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>
> 

no current practice is to stop cluttering pci_ids.h with specific sub-device id's
and just have the vendor values.

