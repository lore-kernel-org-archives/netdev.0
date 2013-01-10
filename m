From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] Use FIELD_SIZEOF().
Date: Wed, 09 Jan 2013 23:38:59 -0800 (PST)
Message-ID: <20130109.233859.1567893842668945487.davem@davemloft.net>
References: <50EDA6A1.6070409@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53232 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932254Ab3AJHjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 02:39:04 -0500
In-Reply-To: <50EDA6A1.6070409@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 10 Jan 2013 02:19:29 +0900

> Use FIELD_SIZEOF() macro instead of dummy pointer to check size
> of cb in struct sk_buff.

Series applied, thanks.
