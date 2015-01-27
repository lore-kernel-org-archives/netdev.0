From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2015-01-26
Date: Tue, 27 Jan 2015 00:28:57 -0800 (PST)
Message-ID: <20150127.002857.1644385416742795122.davem@davemloft.net>
References: <1422258503-26978-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48426 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752978AbbA0I25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:28:57 -0500
In-Reply-To: <1422258503-26978-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 26 Jan 2015 08:48:21 +0100

> Just two small fixes for _decode_session6() where we
> might decode to wrong header information in some rare
> situations.
> 
> Please pull or let me know if there are problems.

Pulled, thanks a lot Steffen.
