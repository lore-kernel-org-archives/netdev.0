From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH] net: mvneta: make mvneta_eth_tool_ops static
Date: Thu, 16 Feb 2017 10:37:22 +0100
Message-ID: <20170216103722.2c22cad5@free-electrons.com>
References: <20170216090739.2632-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:37609 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750718AbdBPJh1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 04:37:27 -0500
In-Reply-To: <20170216090739.2632-1-jszhang@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, 16 Feb 2017 17:07:39 +0800, Jisheng Zhang wrote:
> The mvneta_eth_tool_ops is only used internally in mvneta driver, so
> make it static.
> 
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>

Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
