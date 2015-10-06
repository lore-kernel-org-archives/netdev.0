From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v2 02/13] rocker: rename rocker.h to rocker_hw.h
Date: Mon, 5 Oct 2015 21:41:02 -0700
Message-ID: <CAE4R7bB5RgfW+=2CPRca8mDLPNTyQBAbXC7BDjucEbU8vanFeg@mail.gmail.com>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us> <1444067046-27825-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Thomas Graf <tgraf@suug.ch>,
	Alexei Starovoitov <ast@plumgrid.com>,
	David Laight <David.Laight@aculab.com>,
	john fastabend <john.fastabend@gmail.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:33506 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750934AbbJFElW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 00:41:22 -0400
Received: by oixx17 with SMTP id x17so102596312oix.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 21:41:21 -0700 (PDT)
In-Reply-To: <1444067046-27825-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 5, 2015 at 10:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Since "rocker.h" file is going to be used for different purpose,
> rename the hardware-specific header to "rocker_hw.h".
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>
