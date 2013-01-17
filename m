From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] phy/marvell: remove fiber/copper autoselect on
 88e1111
Date: Thu, 17 Jan 2013 15:47:47 -0500 (EST)
Message-ID: <20130117.154747.1471793083875584682.davem@davemloft.net>
References: <1358436978-7504-1-git-send-email-stef.van.os@prodrive.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chohnstaedt@innominate.com, srinivas.kandagatla@st.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: stef.van.os@prodrive.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53378 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753390Ab3AQUrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 15:47:49 -0500
In-Reply-To: <1358436978-7504-1-git-send-email-stef.van.os@prodrive.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stef van Os <stef.van.os@prodrive.nl>
Date: Thu, 17 Jan 2013 16:36:18 +0100

> Remove the code that always enables copper/fiber autoselect,
> ignoring the DIS_FC strapping pin. The default value for this
> register is autoselect on anyway, and if you explicitly disable
> autoselect via strapping you probably really don't want
> autoselect.
> 
> Signed-off-by: Stef van Os <stef.van.os@prodrive.nl>

Applied, thanks.
