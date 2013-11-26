From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 09/17] net: i40e calls skb_get_rxhash
Date: Tue, 26 Nov 2013 02:22:11 -0800
Message-ID: <CAL3LdT5EAJYpFa_Y3qETwK3E5LJMMAhmKc_Mv3Yr3-PeLMCuXg@mail.gmail.com>
References: <alpine.DEB.2.02.1311252151580.23058@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:61445 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754652Ab3KZKWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 05:22:12 -0500
Received: by mail-oa0-f49.google.com with SMTP id i4so5721228oah.36
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 02:22:12 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1311252151580.23058@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 25, 2013 at 9:52 PM, Tom Herbert <therbert@google.com> wrote:
> Drivers should call skb_get_rxhash to set the rxhash and its type
> in an skbuff.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

I have added the patch to my queue, thanks Tom!
