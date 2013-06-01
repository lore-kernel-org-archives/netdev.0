From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Add support of IPv4 over IPv4 for module
 sit
Date: Fri, 31 May 2013 17:20:10 -0700 (PDT)
Message-ID: <20130531.172010.1146938721859219594.davem@davemloft.net>
References: <1369734496-21961-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755954Ab3FAAUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 20:20:11 -0400
In-Reply-To: <1369734496-21961-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 28 May 2013 11:48:14 +0200

> The goal of this serie is to be able to have IPv4 and IPv6 adresses over the
> same IPv4 tunnel interface. Before this patch, even if encapsulation addresses
> were the same, two interfaces were needed to have 4in4 and 6in4: one 'ipip'
> interface and one 'sit' interface.
> Now, it's possible to configure the mode of the 'sit' interface: 6in4, 4in4 or
> both and thus have only one interface for 6in4 and 4in4.

Looks harmless, applied to net-next, thanks!
