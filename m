From: David Miller <davem@davemloft.net>
Subject: Re: net: stmmac glue layer for Amlogic Meson SoCs
Date: Fri, 26 Sep 2014 00:13:41 -0400 (EDT)
Message-ID: <20140926.001341.1361691136914532479.davem@davemloft.net>
References: <1411219757-9201-1-git-send-email-b.galvani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	carlo@caione.org, jerry.cao@amlogic.com, victor.wan@amlogic.com,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
To: b.galvani@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37491 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbaIZENu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 00:13:50 -0400
In-Reply-To: <1411219757-9201-1-git-send-email-b.galvani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Beniamino Galvani <b.galvani@gmail.com>
Date: Sat, 20 Sep 2014 15:29:15 +0200
> 
> the Ethernet controller available in Amlogic Meson6 and Meson8 SoCs is
> a Synopsys DesignWare MAC IP core, already supported by the stmmac
> driver.
> 
> These patches add a glue layer to the driver for the platform-specific
> settings required by the Amlogic variant.
> 
> This has been tested on a Amlogic S802 device with the initial Meson
> support submitted by Carlo Caione [1].
> 
> [1] http://lwn.net/Articles/612000/

Series applied to net-next, thanks.
