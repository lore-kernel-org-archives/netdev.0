From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH v6 0/3] Add Ethernet support on STM32F429
Date: Thu, 01 Sep 2016 14:03:59 -0700 (PDT)
Message-ID: <20160901.140359.1250526791144876138.davem@davemloft.net>
References: <1472487820-5132-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com, robh@kernel.org,
        manabian@gmail.com
To: alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38752 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756324AbcIAVEB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 17:04:01 -0400
In-Reply-To: <1472487820-5132-1-git-send-email-alexandre.torgue@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandre TORGUE <alexandre.torgue@st.com>
Date: Mon, 29 Aug 2016 18:23:37 +0200

> STM32F429 Chip embeds a Synopsys 3.50a MAC IP.
> 
> This series enhance current stmmac driver to control it (code already
> available) and adds basic glue for STM32F429 chip.

Series applied to net-next, thanks.
