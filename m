From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] forcedeth: remove device id macros
Date: Thu, 04 Jun 2009 02:06:06 -0700 (PDT)
Message-ID: <20090604.020606.229964108.davem@davemloft.net>
References: <4A271DCD.3080903@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, akpm@osdl.org, netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44957
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750885AbZFDJGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 05:06:06 -0400
In-Reply-To: <4A271DCD.3080903@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>
Date: Wed, 03 Jun 2009 21:05:17 -0400

> This patch removes the device id macros and instead uses the constants
> directly.
> 
> The areas in which logic expressions where using the macros now
> instead use feature/workaround flags.
> 
> No new functionality has been introduced in this patch, only clean up
> of flags and macros.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

Applied to net-next-2.6
