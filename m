From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cdc_ncm: return -ENOMEM if kzalloc fails
Date: Sat, 30 Mar 2013 17:31:40 -0400 (EDT)
Message-ID: <20130330.173140.1116638191299891611.davem@davemloft.net>
References: <1364634202-10341-1-git-send-email-devendra.aaru@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: devendra.aaru@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195Ab3C3Vbl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Mar 2013 17:31:41 -0400
In-Reply-To: <1364634202-10341-1-git-send-email-devendra.aaru@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Devendra Naga <devendra.aaru@gmail.com>
Date: Sat, 30 Mar 2013 14:33:22 +0530

> return -ENOMEM instead if kzalloc of cdc_ncm_ctx structure is failed.
> 
> and also remove the comparision of ctx structure with NULL and make
> it as !ctx.
> 
> Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>

Applied.
