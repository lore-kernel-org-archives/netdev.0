From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] of: mdio: fixup of_phy_register_fixed_link parsing
 of new bindings
Date: Sun, 22 Jun 2014 21:35:43 -0700 (PDT)
Message-ID: <20140622.213543.227586714635463282.davem@davemloft.net>
References: <53A35763.4020904@cogentembedded.com>
	<1403273467-16974-1-git-send-email-rretanubun.work@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, thomas.petazzoni@free-electrons.com
To: rretanubun.work@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbaFWEfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 00:35:45 -0400
In-Reply-To: <1403273467-16974-1-git-send-email-rretanubun.work@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Retanubun <rretanubun.work@gmail.com>
Date: Fri, 20 Jun 2014 10:11:07 -0400

> Fixes commit 3be2a49e5c08 ("of: provide a binding for fixed link PHYs")
> 
> Fix the parsing of the new fixed link dts bindings for duplex,
> pause, and asym_pause by using the correct device node pointer.
> 
> Signed-off-by: Richard Retanubun <rretanubun.work@gmail.com>

Applied, thank you.
