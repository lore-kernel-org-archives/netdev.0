From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH] virtio-net: Remove more stack DMA
Date: Thu, 14 Jul 2016 13:21:46 -0700
Message-ID: <CALCETrUUwBdjoznrot7+ufmbzzsC2SZL2g2zy_HjT82Q_AwM1Q@mail.gmail.com>
References: <1ff8c3e69b8d4f1ad717affa073b279a74ee4309.1468272497.git.luto@kernel.org>
 <20160712.104030.1596691470300748311.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:34410 "EHLO
	mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178AbcGNUWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 16:22:07 -0400
Received: by mail-vk0-f47.google.com with SMTP id o63so127929691vkg.1
        for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 13:22:06 -0700 (PDT)
In-Reply-To: <20160712.104030.1596691470300748311.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2016 at 10:40 AM, David Miller <davem@davemloft.net> wrote:
> From: Andy Lutomirski <luto@kernel.org>
> Date: Mon, 11 Jul 2016 14:30:28 -0700
>
>> DaveM, is it okay for this to go in via -tip?
>
> Sure.

Looks like the series that depends on this is getting delayed to 4.9.
Could you queue this patch for net-next instead?

Thanks,
Andy
