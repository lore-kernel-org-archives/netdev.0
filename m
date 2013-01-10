From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] bnx2x: bug fix patch series
Date: Thu, 10 Jan 2013 14:38:14 -0800 (PST)
Message-ID: <20130110.143814.488493399332765477.davem@davemloft.net>
References: <1357829620-17890-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, ariele@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605Ab3AJWiP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 17:38:15 -0500
In-Reply-To: <1357829620-17890-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Thu, 10 Jan 2013 16:53:38 +0200

> Hi Dave,
> 
> This patch series contains 2 bug fixes:
> 
>   1. Failed memory allocation during Tx queue allocation can
>      later cause the driver to dereference incorrect pointers,
>      causing a panic.
> 
>   2. During probe, management traffic is stopped and resumes
>      only after some of its functions gets loaded.
> 
> Please consider applying this patch-series to 'net'.

Applied.
