From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 08/17] net: e1000e calls skb_set_rxhash
Date: Tue, 26 Nov 2013 13:50:07 -0800
Message-ID: <CAL3LdT5BgUUgi2WzoNZ4j6=Odbn42p1QpbVM2wmfxBwZB8i2Ow@mail.gmail.com>
References: <alpine.DEB.2.02.1311260923020.21143@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:46959 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757896Ab3KZVuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 16:50:08 -0500
Received: by mail-ob0-f180.google.com with SMTP id wo20so6497280obc.11
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 13:50:07 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1311260923020.21143@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 26, 2013 at 9:27 AM, Tom Herbert <therbert@google.com> wrote:
> Drivers should call skb_set_rxhash to set the rxhash and its type
> in an skbuff.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

I have added the patch to my queue, thanks Tom!
