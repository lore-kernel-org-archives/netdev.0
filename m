From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 11/17] net: ixgbe calls skb_set_rxhash
Date: Tue, 26 Nov 2013 13:51:44 -0800
Message-ID: <CAL3LdT7A35-S7tzzzJg6PDDFaG+GZqqO7YeVu230XQsaeXoJ_g@mail.gmail.com>
References: <alpine.DEB.2.02.1311260928030.21138@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:56504 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932479Ab3KZVvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 16:51:44 -0500
Received: by mail-oa0-f47.google.com with SMTP id k1so6759324oag.34
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 13:51:44 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1311260928030.21138@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 26, 2013 at 9:31 AM, Tom Herbert <therbert@google.com> wrote:
> Drivers should call skb_set_rxhash to set the rxhash and its type
> in an skbuff.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

I have added the patch to my queue, thanks Tom!
