From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/3] net: stmmac: Correct socfpga init/exit and
Date: Wed, 02 Jul 2014 18:38:20 -0700 (PDT)
Message-ID: <20140702.183820.2063956219014028109.davem@davemloft.net>
References: <1404092093-18630-1-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com, vbridger@altera.com
To: vbridgers2013@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42687 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbaGCBiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 21:38:21 -0400
In-Reply-To: <1404092093-18630-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridgers2013@gmail.com>
Date: Sun, 29 Jun 2014 20:34:50 -0500

> This patch series adds platform specific init/exit code so that socfpga
> suspend/resume works as expected, and corrects a minor issue detected by
> cppcheck. 

Series applied, thanks.
