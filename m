From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: make platform drivers depend on their
 associated SoC
Date: Wed, 01 Jun 2016 21:45:13 -0700 (PDT)
Message-ID: <20160601.214513.1951391011133609260.davem@davemloft.net>
References: <1464784138-27103-1-git-send-email-pbrobinson@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@sciencehorizons.net, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, netdev@vger.kernel.org
To: pbrobinson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbcFBEpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 00:45:17 -0400
In-Reply-To: <1464784138-27103-1-git-send-email-pbrobinson@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Robinson <pbrobinson@gmail.com>
Date: Wed,  1 Jun 2016 13:28:58 +0100

> There's not much point, except compile test, enabling the stmmac
> platform drivers unless their actual SoC is enabled. They're not
> useful without it.
> 
> Signed-off-by: Peter Robinson <pbrobinson@gmail.com>

Seems reasonable, applied, thanks.
