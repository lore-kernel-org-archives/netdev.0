From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH] trivial: net: filter: Change kerneldoc parameter order
Date: Tue, 24 Jun 2014 08:02:02 -0700
Message-ID: <CAMEtUuzne3MApOj=_UjdFD9TC0P0VOYLZ3oNSC1i8-+psbdJ_g@mail.gmail.com>
References: <1403616802-25743-1-git-send-email-tklauser@distanz.ch>
	<1403616802-25743-2-git-send-email-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:38670 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754310AbaFXPCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 11:02:09 -0400
Received: by mail-wi0-f176.google.com with SMTP id n3so6118636wiv.3
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 08:02:04 -0700 (PDT)
In-Reply-To: <1403616802-25743-2-git-send-email-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2014 at 6:33 AM, Tobias Klauser <tklauser@distanz.ch> wrote:
> Change the order of the parameters to sk_unattached_filter_create() in
> the kerneldoc to reflect the order they appear in the actual function.
>
> This fix is only cosmetic, in the generated doc they still appear in the
> correct order without the fix.
>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
