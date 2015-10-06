From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v2 03/13] rocker: rename rocker.c to rocker_main.c
Date: Mon, 5 Oct 2015 21:45:24 -0700
Message-ID: <CAE4R7bB4vwrwBzw0rWcn9J5JfTGK-fMxkZcwx5dary0-f-m83Q@mail.gmail.com>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us> <1444067046-27825-4-git-send-email-jiri@resnulli.us>
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
Received: from mail-ob0-f181.google.com ([209.85.214.181]:33590 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbbJFEpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 00:45:44 -0400
Received: by obbbh8 with SMTP id bh8so145392104obb.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 21:45:43 -0700 (PDT)
In-Reply-To: <1444067046-27825-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 5, 2015 at 10:43 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Since "rocker.c" is going to be split into multiple files, start with
> renaming original "rocker.c" file to "rocker_main.c". Multiple code
> parts are going to be cut from "rocker_main.c" later on.
>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Scott Feldman <sfeldma@gmail.com>
