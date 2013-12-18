From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 06/15] net: e1000e calls skb_set_hash
Date: Wed, 18 Dec 2013 00:38:41 -0800
Message-ID: <CAL3LdT70zJsqSP_j=9XpriVuH+cfmubN7bwFLvO3C7LRaCshwA@mail.gmail.com>
References: <alpine.DEB.2.02.1312172326360.24380@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:45233 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab3LRIil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 03:38:41 -0500
Received: by mail-ob0-f177.google.com with SMTP id vb8so7516562obc.36
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 00:38:41 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1312172326360.24380@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 17, 2013 at 11:27 PM, Tom Herbert <therbert@google.com> wrote:
> Drivers should call skb_set_hash to set the hash and its type
> in an skbuff.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>

I have added this patch to my queue, thanks Tom.
