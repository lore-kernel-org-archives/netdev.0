From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 08/15] net: igb calls skb_set_hash
Date: Wed, 18 Dec 2013 00:40:29 -0800
Message-ID: <CAL3LdT5i0bowkrbf5FWH1STx9Ln0ZLDsSHtSMp+dUDfQ6gJgQA@mail.gmail.com>
References: <alpine.DEB.2.02.1312172325170.24419@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:63593 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883Ab3LRIka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 03:40:30 -0500
Received: by mail-oa0-f43.google.com with SMTP id i7so7900736oag.16
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 00:40:29 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1312172325170.24419@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 17, 2013 at 11:27 PM, Tom Herbert <therbert@google.com> wrote:
> Drivers should call skb_set_hash to set the hash and its type
> in an skbuff.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
>

I have added this patch to my queue, thanks Tom.
