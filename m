From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: Fix clock en-/disable calls
Date: Thu, 07 Jun 2012 13:13:58 -0700 (PDT)
Message-ID: <20120607.131358.813782810012986816.davem@davemloft.net>
References: <1338965351-6286-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viresh.linux@gmail.com,
	peppe.cavallaro@st.com
To: sr@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752224Ab2FGUN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 16:13:59 -0400
In-Reply-To: <1338965351-6286-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Roese <sr@denx.de>
Date: Wed,  6 Jun 2012 08:49:11 +0200

> Signed-off-by: Stefan Roese <sr@denx.de>

This means nothing to me.

What is fixed by using the prepare/unprepare variants vs. the
plain ones?

It is absolutely inappropriate to not describe your change
completely in your commit message.

This patch is being rejected.
