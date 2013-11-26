From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 09/17] net: i40e calls skb_set_rxhash
Date: Tue, 26 Nov 2013 13:50:39 -0800
Message-ID: <CAL3LdT5MDqM4r_yuBUiCwBSr8_ev+eT_0z71Dj-vwy57xwKvZg@mail.gmail.com>
References: <alpine.DEB.2.02.1311260923030.21248@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:35186 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758249Ab3KZVuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 16:50:39 -0500
Received: by mail-ob0-f176.google.com with SMTP id va2so6396438obc.7
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 13:50:39 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1311260923030.21248@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 26, 2013 at 9:27 AM, Tom Herbert <therbert@google.com> wrote:
> Drivers should call skb_set_rxhash to set the rxhash and its type
> in an skbuff.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

I have added the patch to my queue, thanks Tom!
