From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [1/1] connector maintainer/mail update.
Date: Sat, 18 Jul 2009 14:35:55 -0400
Message-ID: <8bd0f97a0907181135w27c8c56al636aefc6bf7b09f8@mail.gmail.com>
References: <1247696049-15699-1-git-send-email-vapier@gentoo.org>
	<20090716101957.GA9586@ioremap.net> <20090717.101550.223298982.davem@davemloft.net>
	<8bd0f97a0907172045j2cff6987xb7ea0aab438bef9d@mail.gmail.com>
	<20090717223307.d86a5551.akpm@linux-foundation.org> <20090718142533.GA1948@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f213.google.com ([209.85.217.213]:61157 "EHLO
	mail-gx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526AbZGRSgP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2009 14:36:15 -0400
Received: by gxk9 with SMTP id 9so2704350gxk.13
        for <netdev@vger.kernel.org>; Sat, 18 Jul 2009 11:36:15 -0700 (PDT)
In-Reply-To: <20090718142533.GA1948@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 18, 2009 at 10:25, Evgeniy Polyakov wrote:
> - * 2004-2005 Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> + * 2004+ Copyright (c) Evgeniy Polyakov <zbr@ioremap.net>

i dont think open-ended copyrights are acceptable.  copyrights arent
something that extend forever which is why they need explicit updating
(i.e. you'd want 2004-<last year you made a change>).

> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> +CONNECTOR
> +P: =C2=A0 =C2=A0 Evgeniy Polyakov
> +M: =C2=A0 =C2=A0 zbr@ioremap.net
> +L: =C2=A0 =C2=A0 netdev@vger.kernel.org
> +S: =C2=A0 =C2=A0 Maintained
> +F: =C2=A0 =C2=A0 drivers/connector/

thanks
-mike
