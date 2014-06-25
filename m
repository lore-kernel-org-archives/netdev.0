From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] net: stmmac: add platform init/exit for
 Altera's ARM socfpga
Date: Wed, 25 Jun 2014 15:59:18 -0700 (PDT)
Message-ID: <20140625.155918.1075841150895163513.davem@davemloft.net>
References: <1403483701-21199-1-git-send-email-vbridgers2013@gmail.com>
	<1403483701-21199-2-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com
To: vbridgers2013@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199AbaFYW7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 18:59:19 -0400
In-Reply-To: <1403483701-21199-2-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridgers2013@gmail.com>
Date: Sun, 22 Jun 2014 19:35:00 -0500

> +	return ret;
> +}
>  const struct stmmac_of_data socfpga_gmac_data = {

Please always place one empty line between top-level declarations.
