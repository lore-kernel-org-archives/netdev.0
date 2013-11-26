From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 08/17] net: e1000e calls skb_get_rxhash
Date: Tue, 26 Nov 2013 02:21:40 -0800
Message-ID: <CAL3LdT6BCw_p2xr2PvC3ts_PsDv=zgjpAyBWsY0CLUZsAZfGXg@mail.gmail.com>
References: <alpine.DEB.2.02.1311252151460.22983@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:37585 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755436Ab3KZKVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 05:21:41 -0500
Received: by mail-ob0-f181.google.com with SMTP id uy5so5452689obc.26
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 02:21:40 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1311252151460.22983@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 25, 2013 at 9:52 PM, Tom Herbert <therbert@google.com> wrote:
> Drivers should call skb_get_rxhash to set the rxhash and its type
> in an skbuff.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>

I have added the patch to my queue, thanks Tom!
