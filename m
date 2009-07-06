From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] sctp: fix warning at inet_sock_destruct() while
 release sctp socket
Date: Mon, 06 Jul 2009 13:08:06 -0700 (PDT)
Message-ID: <20090706.130806.164243441.davem@davemloft.net>
References: <4A518F8C.2090807@cn.fujitsu.com>
	<20090706064957.GA16971@gondor.apana.org.au>
	<4A51FFDD.30108@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, yjwei@cn.fujitsu.com,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34914
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754433AbZGFUIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 16:08:04 -0400
In-Reply-To: <4A51FFDD.30108@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 06 Jul 2009 09:45:01 -0400

> Herbert Xu wrote:
>> On Mon, Jul 06, 2009 at 01:45:48PM +0800, Wei Yongjun wrote:
>>> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
>> 
>> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied, thanks everyone.
