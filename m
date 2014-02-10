From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 1/2] net: stmmac: Add SOCFPGA glue driver
Date: Sun, 09 Feb 2014 18:06:42 -0800 (PST)
Message-ID: <20140209.180642.1194468196963903290.davem@davemloft.net>
References: <1391728795-30435-1-git-send-email-dinguyen@altera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dinh.linux@gmail.com,
	devicetree@vger.kernel.org, peppe.cavallaro@st.com,
	robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	vbridgers2013@gmail.com
To: dinguyen@altera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbaBJCGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 21:06:43 -0500
In-Reply-To: <1391728795-30435-1-git-send-email-dinguyen@altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <dinguyen@altera.com>
Date: Thu, 6 Feb 2014 17:19:54 -0600

> +MODULE_ALIAS("platform:socfpga-dwmac");
> +MODULE_AUTHOR("Dinh Nguyen <dinguyen@altera.com>");
> +MODULE_LICENSE("GPL v2");
> +MODULE_DESCRIPTION("Altera SOCFPGA DWMAC Glue Layer");
> +

Do not add stray empty lines at the end of files.  Your second patch
has this problem is a few places too.
