From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless-2.6 2011-04-22
Date: Fri, 22 Apr 2011 13:21:48 -0700 (PDT)
Message-ID: <20110422.132148.189688282.davem@davemloft.net>
References: <20110422201142.GA27119@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49588
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756409Ab1DVUWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 16:22:22 -0400
In-Reply-To: <20110422201142.GA27119@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 22 Apr 2011 16:11:43 -0400

> Here are some fixes intended for 2.6.39...
> 
> This includes a Bluetooth pull, described thusly by Gustavo:
> 
> 	Four small fixes for 2.6.39. An incorrect refcnt balance for
> 	hci connection by Ville Tervo, a warning fix in the command
> 	timer by Vinicius Gomes, an ERTM fix by Ruiyi Zhang, and SCO
> 	synchronization fix by Luiz Augusto von Dentz.
> 
> On top of those, there are some use-after-free fixes from Stansilaw for
> iwlegacy and iwlwifi, a mac80211 debugfs locking fix from Johannes, and
> a small logic fix for the return code of ath9k's ah_stoprecv from Felix,
> and an iwlwifi fix for frame injection from Daniel Halperin.
> 
> Please let me know if there are problems!

Pulled, thanks John.
