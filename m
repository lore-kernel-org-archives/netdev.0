From: Allen <allen.lkml@gmail.com>
Subject: Re: [PATCH 01/10] arch:powerpc: return -ENOMEM on failed allocation
Date: Thu, 14 Sep 2017 10:13:38 +0530
Message-ID: <CAOMdWSJvQMNJSnfekmM=N-CCaaJF_3HkP8ypZG+vWgWf0gWgfw@mail.gmail.com>
References: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com> <1505314401.8969.11.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-kernel@vger.kernel.org, nouveau@lists.freedesktop.org,
        linux-crypto@vger.kernel.org, dri-devel@lists.freedesktop.org,
        MPT-FusionLinux.pdl@broadcom.com, linux-scsi@vger.kernel.org,
        netdev@vger.kernel.org, megaraidlinux.pdl@broadcom.com,
        target-devel@vger.kernel.org, linux-fbdev@vger.kernel.org,
        linux-btrfs@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33630 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750740AbdINEnl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 00:43:41 -0400
In-Reply-To: <1505314401.8969.11.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think the changelog for this series of conversions
> should show that you've validated the change by
> inspecting the return call chain at each modified line.
>
> Also, it seems you've cc'd the same mailing lists for
> all of the patches modified by this series.
>
> It would be better to individually address each patch
> in the series only cc'ing the appropriate maintainers
> and mailing lists.
>
> A cover letter would be good too.

 Point noted. Thanks.

- Allen
