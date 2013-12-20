From: chenweilong <chenweilong@huawei.com>
Subject: Re: [patch net-next 2/5] xfrm: checkpatch errors with foo * bar
Date: Fri, 20 Dec 2013 16:54:14 +0800
Message-ID: <52B405B6.4070407@huawei.com>
References: <1387455734-7624-1-git-send-email-chenweilong@huawei.com> <1387455734-7624-3-git-send-email-chenweilong@huawei.com> <20131220085029.GM31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:11437 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754600Ab3LTIzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 03:55:21 -0500
In-Reply-To: <20131220085029.GM31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/20 16:50, Steffen Klassert wrote:
> On Thu, Dec 19, 2013 at 08:22:11PM +0800, Chen Weilong wrote:
>> From: Weilong Chen <chenweilong@huawei.com>
>>
>> This patch clean up some checkpatch errors like this:
>> ERROR: "foo * bar" should be "foo *bar"
>> ERROR: "(foo*)" should be "(foo *)"
>>
>> Signed-off-by: Weilong Chen <chenweilong@huawei.com>
> 
> This patch does not apply to the ipsec-next tree.
> Please rebase your patchset to ipsec-next and resend.
> 
> Thanks!
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
OK,I'll do that,Thanks!
