From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 07/15] net: i40e calls skb_set_hash
Date: Wed, 18 Dec 2013 00:39:45 -0800
Message-ID: <CAL3LdT4M0gHP5bW3A1GDJGy2zrt4+YQpK3i8WhAp31N2yHsQkg@mail.gmail.com>
References: <alpine.DEB.2.02.1312172325550.24389@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:52079 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990Ab3LRIjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 03:39:46 -0500
Received: by mail-ob0-f178.google.com with SMTP id uz6so7625640obc.9
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 00:39:45 -0800 (PST)
In-Reply-To: <alpine.DEB.2.02.1312172325550.24389@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 17, 2013 at 11:27 PM, Tom Herbert <therbert@google.com> wrote:
> Drivers should call skb_set_hash to set the hash and its type
> in an skbuff.
>
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>

I have added this patch to my queue, thanks Tom.
