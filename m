From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [patch net-next 2/5] xfrm: checkpatch errors with foo * bar
Date: Fri, 20 Dec 2013 09:50:29 +0100
Message-ID: <20131220085029.GM31491@secunet.com>
References: <1387455734-7624-1-git-send-email-chenweilong@huawei.com>
 <1387455734-7624-3-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org
To: Chen Weilong <chenweilong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43554 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753541Ab3LTIuc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 03:50:32 -0500
Content-Disposition: inline
In-Reply-To: <1387455734-7624-3-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 08:22:11PM +0800, Chen Weilong wrote:
> From: Weilong Chen <chenweilong@huawei.com>
> 
> This patch clean up some checkpatch errors like this:
> ERROR: "foo * bar" should be "foo *bar"
> ERROR: "(foo*)" should be "(foo *)"
> 
> Signed-off-by: Weilong Chen <chenweilong@huawei.com>

This patch does not apply to the ipsec-next tree.
Please rebase your patchset to ipsec-next and resend.

Thanks!
