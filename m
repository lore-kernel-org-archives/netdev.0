From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make struct in_addr::s_addr __be32
Date: Mon, 28 Aug 2006 23:58:07 -0700 (PDT)
Message-ID: <20060828.235807.97293694.davem@davemloft.net>
References: <20060820232051.GB5208@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:52709
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932113AbWH2G6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 02:58:09 -0400
To: adobriyan@gmail.com
In-Reply-To: <20060820232051.GB5208@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 21 Aug 2006 03:20:51 +0400

> There will be relatively small increase in sparse endian warnings, but
> this (and sin_port) patch is a first step to make networking code endian
> clean.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks Alexey.
