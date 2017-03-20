From: Saeed Mahameed <saeedm@mellanox.com>
Subject: Re: mlx5e backports for v4.9 -stable
Date: Mon, 20 Mar 2017 23:32:57 +0200
Message-ID: <a53a8f31-a01f-50ee-7aef-4c1a37f2c393@mellanox.com>
References: <20170316.170631.2026655873781156952.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0055.outbound.protection.outlook.com ([104.47.1.55]:48080
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753046AbdCTVdP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 17:33:15 -0400
In-Reply-To: <20170316.170631.2026655873781156952.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/17/2017 02:06 AM, David Miller wrote:
> 
> Commits:
> 
> ====================
> From b0d4660b4cc52e6477ca3a43435351d565dfcedc Mon Sep 17 00:00:00 2001
> From: Tariq Toukan <tariqt@mellanox.com>
> Date: Wed, 22 Feb 2017 17:20:14 +0200
> Subject: [PATCH] net/mlx5e: Fix broken CQE compression initialization
> ====================
> 
> and
> 
> ====================
> From 6dc4b54e77282caf17f0ff72aa32dd296037fbc0 Mon Sep 17 00:00:00 2001
> From: Saeed Mahameed <saeedm@mellanox.com>
> Date: Wed, 22 Feb 2017 17:20:15 +0200
> Subject: [PATCH] net/mlx5e: Update MPWQE stride size when modifying CQE
>  compress state
> ====================
> 
> do not apply even closely to v4.9 while I was working on -stable backports.
> 
> Please provide proper backports of these two patches if you want them to
> show up in v4.9 -stable.
> 

Hi Dave,

thank you for trying, we will provide the patches, but I don't know what is the right procedure
to do so.

is it ok to post the patches applied on top tag v4.9.16  of kernel/git/stable/linux-stable.git ?
to whom should I send them ? 

thanks,
Saeed.
