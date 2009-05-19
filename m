From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [PATCH 1/2] 3c50x: convert printk() to pr_foo()
Date: Wed, 20 May 2009 01:27:20 +0400
Message-ID: <a4423d670905191427i472148abj47288eada4e1e199@mail.gmail.com>
References: <1242756539-19049-1-git-send-email-a.beregalov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Beregalov <a.beregalov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:48980 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbZESV1U convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 17:27:20 -0400
Received: by bwz22 with SMTP id 22so62416bwz.37
        for <netdev@vger.kernel.org>; Tue, 19 May 2009 14:27:20 -0700 (PDT)
In-Reply-To: <1242756539-19049-1-git-send-email-a.beregalov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/5/19 Alexander Beregalov <a.beregalov@gmail.com>:
> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
> ---
>
> Compile tested.
>
>
> =C2=A0drivers/net/3c501.c | =C2=A0 55 +++++++--------
> =C2=A0drivers/net/3c503.c | =C2=A0 36 +++++-----
> =C2=A0drivers/net/3c505.c | =C2=A0191 +++++++++++++++++++++++++------=
--------------------
> =C2=A0drivers/net/3c507.c | =C2=A0 47 ++++++-------
> =C2=A0drivers/net/3c509.c | =C2=A0 60 ++++++++--------
> =C2=A05 files changed, 193 insertions(+), 196 deletions(-)
>

I do not use pr_cont when it is needed.
Please do not pull both patches, I will make a new version.
