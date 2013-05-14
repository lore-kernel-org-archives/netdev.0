From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 0/2] tg3: 2 bugfixes - TSO data corruption and
 phy power down
Date: Tue, 14 May 2013 11:32:24 -0700 (PDT)
Message-ID: <20130514.113224.1003248278387901684.davem@davemloft.net>
References: <1368479056-11780-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43483 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755416Ab3ENSc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 14:32:28 -0400
In-Reply-To: <1368479056-11780-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Mon, 13 May 2013 14:04:14 -0700

> v2:
>  - Modify tg3_phy_power_bug() function to use a switch instead of a
>    complicated if statement. Suggested by Joe Perches.
> 
> Michael Chan (1):
>   tg3: Fix data corruption on 5725 with TSO
> 
> Nithin Nayak Sujir (1):
>   tg3: Skip powering down function 0 on certain serdes devices

All applied, thanks.
