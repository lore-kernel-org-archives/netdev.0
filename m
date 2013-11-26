From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 11/17] net: ixgbe calls skb_get_rxhash
Date: Tue, 26 Nov 2013 02:23:13 -0800
Message-ID: <CAL3LdT6uxdy9STKr2vHdqFOnYdmeW2wt63zvEZcxBQKNw2HP7w@mail.gmail.com>
References: <alpine.DEB.2.02.1311252153050.23058@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:49815 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756074Ab3KZKXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 05:23:14 -0500
Received: by mail-oa0-f43.google.com with SMTP id i7so5762938oag.16
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 02:23:13 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1311252153050.23058@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 25, 2013 at 9:54 PM, Tom Herbert <therbert@google.com> wrote:
> Drivers should call skb_get_rxhash to set the rxhash and its type
> in an skbuff.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

I have added the patch to my queue, thanks Tom!
