From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] NET: MIPS: lantiq: make etop ethernet work on
 ase/ar9
Date: Wed, 16 Nov 2011 22:02:20 -0500 (EST)
Message-ID: <20111116.220220.2004448468476437215.davem@davemloft.net>
References: <1321454508-4754-1-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: blogic@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54701 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755365Ab1KQDCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 22:02:25 -0500
In-Reply-To: <1321454508-4754-1-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Crispin <blogic@openwrt.org>
Date: Wed, 16 Nov 2011 15:41:46 +0100

> Extend the driver to handle the different DMA channel layout for AR9 and
> Amazon-SE SoCs. The patch also adds support for the integrated PHY found
> on Amazon-SE and the gigabit switch found inside the AR9.
> 
> Signed-off-by: John Crispin <blogic@openwrt.org>
> Cc: netdev@vger.kernel.org

Since these patches (at least partially) modify MIPS files, please submit
them via the MIPS maintainer.

Feel free to add:

Acked-by: David S. Miller <davem@davemloft.net>
