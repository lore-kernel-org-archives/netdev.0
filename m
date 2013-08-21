From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 2/2] stmmac: remove useless csum flag
Date: Wed, 21 Aug 2013 00:06:00 -0700 (PDT)
Message-ID: <20130821.000600.1770175220773794518.davem@davemloft.net>
References: <1377062908-16543-1-git-send-email-peppe.cavallaro@st.com>
	<1377062908-16543-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sonic.zhang@analog.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52559 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752495Ab3HUHGC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 03:06:02 -0400
In-Reply-To: <1377062908-16543-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 21 Aug 2013 07:28:28 +0200

> This patch removes the no_csum_insertion private parameter that is not used anymore
> and, also,  the "likely" annotation from the condition that is not in a critical path.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

This is absolutely just a cleanup and therefore not suitable for 'net',
resubmit your changes targetted to the correct tree, 'net-next'.

Thank you.
