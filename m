From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: Re: [PATCH] bnx2x: Fix compiler warnings
Date: Sun, 12 Aug 2012 07:50:48 +0300
Message-ID: <50273628.50503@broadcom.com>
References: <1344741035-1493-1-git-send-email-joren.vanonder@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Joren Van Onder" <joren.vanonder@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1115 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750711Ab2HLEuC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Aug 2012 00:50:02 -0400
In-Reply-To: <1344741035-1493-1-git-send-email-joren.vanonder@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Fix the following compiler warnings:
> 
>  - drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c:2908:3: warning: comparison
>    of distinct pointer types lacks a cast [enabled by default]
>  - drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c:1709:7: warning: comparison
>    of distinct pointer types lacks a cast [enabled by default]
> 
> Signed-off-by: Joren Van Onder <joren.vanonder@gmail.com>
Thanks Joren.
Acked-By: Yuval Mintz <yuvalmin@broadcom.com>
