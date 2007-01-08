From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [git patches] net driver fixes
Date: Mon, 8 Jan 2007 15:17:18 -0600
Message-ID: <FBDB5150-A11D-44C7-9EF8-AE3BB6C92785@kernel.crashing.org>
References: <989B956029373F45A0B8AF02970818900865B5@zch01exm26.fsl.freescale.net> <45A22DA8.2030308@garzik.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Li Yang-r58472 <LeoLi@freescale.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:52382 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750976AbXAHVRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jan 2007 16:17:22 -0500
In-Reply-To: <45A22DA8.2030308@garzik.org>
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Jan 8, 2007, at 5:40 AM, Jeff Garzik wrote:

> Li Yang-r58472 wrote:
>> Hi Jeff,
>> Could you apply the updates for ucc_geth driver?
>> The patches from Timur that make the driver compile correctly on  
>> 2.6.20.
>> [PATCH] Fix phy_read/write redefinition errors in ucc_geth_phy.c
>> [PATCH] Update ucc_geth.c for new workqueue structure
>> The patch from Ahmed that cleans up some unnecessary casts.
>> [PATCH 2.6.20-rc3] UCC Ether driver: kmalloc casting cleanups
>
> I don't have any of these in my queue.

Here's links to the orig patches:

http://marc.theaimsgroup.com/?l=linux-netdev&m=116605401912152&w=2
http://marc.theaimsgroup.com/?l=linux-netdev&m=116605366909148&w=2

- k
