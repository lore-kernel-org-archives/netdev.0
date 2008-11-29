From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: add suspend/resume into the PHY drivers
Date: Fri, 28 Nov 2008 16:38:29 -0800 (PST)
Message-ID: <20081128.163829.112979971.davem@davemloft.net>
References: <1227794239-19897-1-git-send-email-peppe.cavallaro@st.com>
	<20081128.163604.31265829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38213
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752030AbYK2Ai3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 19:38:29 -0500
In-Reply-To: <20081128.163604.31265829.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 28 Nov 2008 16:36:04 -0800 (PST)

> Also, you have a driver in your tree which does not exist upstream,
> drivers/net/phy/national.c, so this patch wouldn't apply correctly
> anyways.

Nevermind, this part is my fault.
