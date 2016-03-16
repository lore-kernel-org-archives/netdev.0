From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net-next.git) 0/2] STMMAC: MDIO settings
Date: Wed, 16 Mar 2016 18:09:05 -0400 (EDT)
Message-ID: <20160316.180905.1210684680763742658.davem@davemloft.net>
References: <1458121942-5537-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gabriel.fernandez@linaro.org,
	afaerber@suse.de, fschaefer.oss@googlemail.com,
	dinh.linux@gmail.com, preid@electromag.com.au
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51802 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbcCPWJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 18:09:08 -0400
In-Reply-To: <1458121942-5537-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Don't _ever_ send the same two sets of patches targetting net and
net-next at the same time.

Especially right now, as 'net' is basically frozen, and 'net-next' is
closed for new features and is only for last minute bug fixes before I
send a merge window pull request to Linus.

I'm tossing both of these series, figure it how to do this properly.
