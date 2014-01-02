From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] socket: cleanup
Date: Wed, 01 Jan 2014 23:40:52 -0500 (EST)
Message-ID: <20140101.234052.354258746748248104.davem@davemloft.net>
References: <20131230104012.3ecea4d5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46441 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140AbaABEkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 23:40:53 -0500
In-Reply-To: <20131230104012.3ecea4d5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 30 Dec 2013 10:40:12 -0800

> -void cred_to_ucred(struct pid *pid, const struct cred *cred,
> +static void cred_to_ucred(struct pid *pid, const struct cred *cred,
>  		   struct ucred *ucred)

Please reindent the args.
