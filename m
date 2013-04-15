From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] esp4: fix error return code in esp_output()
Date: Mon, 15 Apr 2013 10:06:55 +0200
Message-ID: <20130415080655.GJ21448@secunet.com>
References: <CAPgLHd9zivXBfC5DvuKwr+C3vX+-kJjqSrLRRyAvk=nmBvGaaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35999 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932513Ab3DOIG6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Apr 2013 04:06:58 -0400
Content-Disposition: inline
In-Reply-To: <CAPgLHd9zivXBfC5DvuKwr+C3vX+-kJjqSrLRRyAvk=nmBvGaaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 14, 2013 at 09:49:03AM +0800, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Fix to return a negative error code from the error handling
> case instead of 0, as returned elsewhere in this function.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Thanks for catching this!

Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
