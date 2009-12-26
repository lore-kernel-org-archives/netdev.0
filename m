From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH 2/4] stmmac: add the new Header file for stmmac
 platform data
Date: Fri, 25 Dec 2009 18:25:01 -0800 (PST)
Message-ID: <20091225.182501.39194553.davem@davemloft.net>
References: <1260948405-28511-1-git-send-email-peppe.cavallaro@st.com>
	<1260948405-28511-2-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41402
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752095AbZLZCY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2009 21:24:59 -0500
In-Reply-To: <1260948405-28511-2-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 16 Dec 2009 08:26:43 +0100

> +#define __STMMAC_PLATFORM_DATA __FILE__

Why is this defining this to __FILE__?  An empty
definition is colloquial and sufficient.
