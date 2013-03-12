From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] bnx2x: use list_move instead of list_del/list_add
Date: Tue, 12 Mar 2013 08:15:34 -0400 (EDT)
Message-ID: <20130312.081534.1945206332357326713.davem@davemloft.net>
References: <CAPgLHd8f_Vq40sB9SaD-3wsHp34ifQ7X+uoMUNDfjFHcy4wJkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755311Ab3CLMPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 08:15:21 -0400
In-Reply-To: <CAPgLHd8f_Vq40sB9SaD-3wsHp34ifQ7X+uoMUNDfjFHcy4wJkQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 11 Mar 2013 22:40:14 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Using list_move() instead of list_del() + list_add().
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
