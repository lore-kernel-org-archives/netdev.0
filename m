From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] r8169:fix system hange problem.
Date: Sat, 13 Feb 2016 05:59:22 -0500 (EST)
Message-ID: <20160213.055922.1650779186632648002.davem@davemloft.net>
References: <1454610480-3274-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: hau@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48232 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293AbcBMK7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2016 05:59:25 -0500
In-Reply-To: <1454610480-3274-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chunhao Lin <hau@realtek.com>
Date: Fri, 5 Feb 2016 02:28:00 +0800

> There are typos in setting RTL8168H hardware parameters. If system install
> another version driver that may cuase system hang.
> 
> Signed-off-by: Chunhao Lin <hau@realtek.com>

Applied to 'net'.
