From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netfront: use skb_partial_csum_set() to
 simplify the codes
Date: Tue, 11 Jun 2013 02:35:05 -0700 (PDT)
Message-ID: <20130611.023505.870956875845907573.davem@davemloft.net>
References: <1370500519-2244-1-git-send-email-roy.qing.li@gmail.com>
	<51B14DF9.2060400@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roy.qing.li@gmail.com, netdev@vger.kernel.org
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37597 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984Ab3FKJfG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 05:35:06 -0400
In-Reply-To: <51B14DF9.2060400@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 07 Jun 2013 11:05:29 +0800

> On 06/06/2013 02:35 PM, roy.qing.li@gmail.com wrote:
>> From: Li RongQing <roy.qing.li@gmail.com>
>>
>> use skb_partial_csum_set() to simplify the codes
>>
>> Cc: Jason Wang <jasowang@redhat.com>
>> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
 ...
> Acked-by: Jason Wang <jasowang@redhat.com>

Applied, thanks.
