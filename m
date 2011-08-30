From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] qlcnic: Bug fixes
Date: Mon, 29 Aug 2011 22:53:49 -0400 (EDT)
Message-ID: <20110829.225349.1923128877827649214.davem@davemloft.net>
References: <1314658231-30735-1-git-send-email-sony.chacko@qlogic.com>
	<1314658231-30735-6-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33703 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769Ab1H3Cxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 22:53:54 -0400
In-Reply-To: <1314658231-30735-6-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>
Date: Mon, 29 Aug 2011 15:50:31 -0700

> Please apply to net-next.

Applied, thanks.

I would like to suggest that you move away from driver internal
debug logging macros and either use existing generic kernel
facilities that exist or extend what exists so that it fits
your needs and others can enjoy the improvements too.

Thanks.
