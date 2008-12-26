From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/27] drivers/net/cxgb3: comment out dead code
Date: Thu, 25 Dec 2008 23:59:38 -0800 (PST)
Message-ID: <20081225.235938.00539364.davem@davemloft.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	<20081222191603.11807.61006.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37918
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753185AbYLZH7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 02:59:36 -0500
In-Reply-To: <20081222191603.11807.61006.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Mon, 22 Dec 2008 20:16:03 +0100

> The function 'vsc8211_set_speed_duplex' is not used, so comment it
> out.  For 'vsc8211_set_automdi' the function 'vsc8211_set_speed_duplex'
> is the only caller, so comment it out as well.
> 
> Fix this (sparse) warning:
 ...
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Applied.
