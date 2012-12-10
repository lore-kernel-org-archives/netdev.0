From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] inet_diag: validate port comparison byte code to
 prevent unsafe reads
Date: Mon, 10 Dec 2012 00:17:28 -0500
Message-ID: <CADVnQynV9d5s+Pr4qHjaHGiOYw_=Gri=CcQkJHiQjDe_D+aPJg@mail.gmail.com>
References: <1355086980-30438-1-git-send-email-ncardwell@google.com>
	<20121209.190223.1179297442063515404.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <edumazet@google.com>, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:54531 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750696Ab2LJFR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2012 00:17:29 -0500
Received: by mail-ie0-f170.google.com with SMTP id k10so7706241iea.29
        for <netdev@vger.kernel.org>; Sun, 09 Dec 2012 21:17:28 -0800 (PST)
In-Reply-To: <20121209.190223.1179297442063515404.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 9, 2012 at 7:02 PM, David Miller <davem@davemloft.net> wrote:
> I added the missing "return true" at the end of this new function.
>
> Applied, but please be more careful and at least look at the compiler
> warnings when you submit your changes.
>
> Thanks.

Roger that. Oof. Can't believe I missed that.

thanks,
neal
