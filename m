From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] rocker: mark parameters and local
 variables as const
Date: Wed, 13 May 2015 20:57:09 -0700
Message-ID: <CAE4R7bAVRQoZj2qKUusPdVXDAv5+61-spUv+WESd-2zyyH26Gw@mail.gmail.com>
References: <1431574976-18214-1-git-send-email-simon.horman@netronome.com>
	<1431574976-18214-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35937 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933031AbbEND5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 23:57:10 -0400
Received: by qkgw4 with SMTP id w4so2127816qkg.3
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 20:57:09 -0700 (PDT)
In-Reply-To: <1431574976-18214-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2015 at 8:42 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> Mark parameters and local variables as const where possible.
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
>
> ---
> v2
> * Make more parameters and variables const.
>   It seems that I missed quite a few the first time around.
>
>   The more I look over this the more I feel others are lurking.

Acked-by: Scott Feldman <sfeldma@gmail.com>
