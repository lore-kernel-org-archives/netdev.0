From: Pavlos Parissis <pavlos.parissis@gmail.com>
Subject: Re: [Intel-wired-lan] [jkirsher/net-queue PATCH] i40e: Add
 programming descriptors to cleaned_count
Date: Sat, 28 Oct 2017 00:58:25 +0200
Message-ID: <CABOTfnM8OLguVSCq3bSHNObfiU1Es4O3d7T+-W9LGVU=NS5-dg@mail.gmail.com>
References: <20171022011222.12997.53593.stgit@localhost.localdomain>
 <1508695307.4970.32.camel@cohaesio.com> <003ecf6b-bd50-51fa-79a7-eab2b100257b@itcare.pl>
 <CABOTfnPBWaGhwpr8tBZ46piLqRR68LTyr=-cyj3kDESpuybjTA@mail.gmail.com> <4b65ab35-b216-e13d-3676-03360bc5d47b@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "Anders K. Pedersen | Cohaesio" <akp@cohaesio.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
To: =?UTF-8?Q?Pawe=C5=82_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:44897 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751568AbdJ0W61 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 18:58:27 -0400
Received: by mail-qt0-f181.google.com with SMTP id 8so10295996qtv.1
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 15:58:26 -0700 (PDT)
In-Reply-To: <4b65ab35-b216-e13d-3676-03360bc5d47b@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 October 2017 at 00:21, Pawe=C5=82 Staszewski <pstaszewski@itcare.pl> =
wrote:
> from today it is in net.git
>
> https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git/log/?qt=3Dg=
rep&q=3Di40e
>
> It will be later in net-next
>
>

I have to admit I am not that familiar with repo layout, I though
net-next holds what is going to be pushed to Linus's repo and
potentially some parts to linux-stable.

> Also can You please tell me what firmware You are using with Your nics ?
>

1.1752.0., but we use the firmware version that comes from HP, as we
use HP servers, see details here
https://communities.intel.com/message/501682#501682

> Those are X710 ?

Correct.

Cheers,
Pavlos
