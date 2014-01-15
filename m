From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] atheros: modify statistics code
Date: Tue, 14 Jan 2014 17:18:51 -0800 (PST)
Message-ID: <20140114.171851.500245804015775555.davem@davemloft.net>
References: <1389549040-8785-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	jcliburn@gmail.com, chris.snook@gmail.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbaAOBSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 20:18:52 -0500
In-Reply-To: <1389549040-8785-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Sun, 12 Jan 2014 18:50:37 +0100

> Following Ben Hutchings's advice on how to fill net_stats in alx [1],
> this patch modifies the other atheros ethernet drivers
> similarly. Minor whitespace/empty line changes in atl1c and atl1e to
> make the code completely consistent between atl1c, atl1e, and alx.
> 
> I don't have this hardware, so these patches have only been
> compile-tested.

Series applied, thanks Sabrina.
