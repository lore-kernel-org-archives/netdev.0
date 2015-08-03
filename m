From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next 1/2] rocker: enable support for scattered packets
Date: Mon, 3 Aug 2015 11:30:38 -0700
Message-ID: <CAE4R7bAXXs1zg4P3TGY+J8truLBoKr1DEW-fJMePke6k1JoXZg@mail.gmail.com>
References: <1438541798-1725-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:35047 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754571AbbHCSa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 14:30:58 -0400
Received: by obbop1 with SMTP id op1so105776926obb.2
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 11:30:57 -0700 (PDT)
In-Reply-To: <1438541798-1725-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 2, 2015 at 11:56 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Ido Schimmel <idosch@mellanox.com>
>
> rocker supports the transmission of scattered packets, so let the kernel
> know about it by setting the NETIF_F_SG bit in the device's features.
>
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Acked-by: Scott Feldman <sfeldma@gmail.com>
