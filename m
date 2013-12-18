From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 09/15] net: ixgbe calls skb_set_hash
Date: Wed, 18 Dec 2013 00:41:06 -0800
Message-ID: <CAL3LdT7HC0EcYdbTxYe6OEy_cy6EbL1udafhwJA1VWCFv5gG1w@mail.gmail.com>
References: <alpine.DEB.2.02.1312172324380.24772@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:56061 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752767Ab3LRIlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 03:41:07 -0500
Received: by mail-oa0-f41.google.com with SMTP id j17so7957018oag.0
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 00:41:06 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1312172324380.24772@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 17, 2013 at 11:28 PM, Tom Herbert <therbert@google.com> wrote:
> Drivers should call skb_set_hash to set the hash and its type
> in an skbuff.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>

I have added this patch to my queue, thanks Tom.
