From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] be2net: Staticize local functions
Date: Mon, 05 Aug 2013 11:10:17 -0700 (PDT)
Message-ID: <20130805.111017.74692698586831888.davem@davemloft.net>
References: <002201ce91ba$7335bfd0$59a13f70$@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47541 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752915Ab3HESKR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 14:10:17 -0400
In-Reply-To: <002201ce91ba$7335bfd0$59a13f70$@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Mon, 05 Aug 2013 18:02:02 +0900

> These local functions are used only in this file.
> Fix the following sparse warnings:
 ...
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
