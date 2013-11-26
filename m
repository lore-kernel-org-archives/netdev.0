From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 10/17] net: igb calls skb_get_rxhash
Date: Tue, 26 Nov 2013 02:22:41 -0800
Message-ID: <CAL3LdT6da-yrcqeTCNxw3teT+3vkNvKnG7Qz+bEE_8e+pCQpZg@mail.gmail.com>
References: <alpine.DEB.2.02.1311252153020.22983@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:63257 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754652Ab3KZKWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 05:22:42 -0500
Received: by mail-ob0-f180.google.com with SMTP id wo20so5576929obc.11
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 02:22:41 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1311252153020.22983@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 25, 2013 at 9:54 PM, Tom Herbert <therbert@google.com> wrote:
> Drivers should call skb_get_rxhash to set the rxhash and its type
> in an skbuff.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

I have added the patch to my queue, thanks Tom!
