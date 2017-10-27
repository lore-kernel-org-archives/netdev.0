From: Pavlos Parissis <pavlos.parissis@gmail.com>
Subject: Re: [Intel-wired-lan] [jkirsher/net-queue PATCH] i40e: Add
 programming descriptors to cleaned_count
Date: Fri, 27 Oct 2017 23:20:07 +0200
Message-ID: <CABOTfnPBWaGhwpr8tBZ46piLqRR68LTyr=-cyj3kDESpuybjTA@mail.gmail.com>
References: <20171022011222.12997.53593.stgit@localhost.localdomain>
 <1508695307.4970.32.camel@cohaesio.com> <003ecf6b-bd50-51fa-79a7-eab2b100257b@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
To: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:44028 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752311AbdJ0VUI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 17:20:08 -0400
Received: by mail-qk0-f179.google.com with SMTP id w134so9968106qkb.0
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 14:20:08 -0700 (PDT)
In-Reply-To: <003ecf6b-bd50-51fa-79a7-eab2b100257b@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23 October 2017 at 01:15, Pawe=C5=82 Staszewski <pstaszewski@itcare.pl> =
wrote:
> Yes can confirm that after adding patch:
>
> [jkirsher/net-queue PATCH] i40e: Add programming descriptors to
> cleaned_count
>
>
> There is no memleak.
>
>

Somehow this patch isn't present in the current net-next repo.
Shouldn't it be there?

Cheers,
Pavlos
