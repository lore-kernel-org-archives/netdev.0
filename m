From: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Subject: Re: [PATCH] net: NEWEMAC: Remove "rgmii-interface" from rgmii
 matching table
Date: Wed, 6 Feb 2008 06:49:47 -0600
Message-ID: <20080206064947.7e91d833@zod.rchland.ibm.com>
References: <1202300519-7294-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, benh@kernel.crashing.org,
	linuxppc-dev@ozlabs.org
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:51746 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759806AbYBFMuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 07:50:04 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m16Co2Se010199
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 07:50:02 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m16Co2aF205240
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 05:50:02 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m16Co1hk015828
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 05:50:02 -0700
In-Reply-To: <1202300519-7294-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  6 Feb 2008 13:21:59 +0100
Stefan Roese <sr@denx.de> wrote:

> With the removal the the "rgmii-interface" device_type property from the
> dts files, the newemac driver needs an update to only rely on compatible
> property.
> 
> Signed-off-by: Stefan Roese <sr@denx.de>
> Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

Acked-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>

josh
