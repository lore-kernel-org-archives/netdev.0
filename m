From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 2/7] turn Makefile more distribution friendly
Date: Mon, 20 Apr 2015 09:55:15 -0700
Message-ID: <20150420095515.1578733e@urahara>
References: <1428933661-8193-2-git-send-email-pavlix@pavlix.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, psimerda@redhat.com
To: Pavel =?UTF-8?B?xaBpbWVyZGE=?= <pavlix@pavlix.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33274 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998AbbDTQzL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 12:55:11 -0400
Received: by paboj16 with SMTP id oj16so212225388pab.0
        for <netdev@vger.kernel.org>; Mon, 20 Apr 2015 09:55:11 -0700 (PDT)
In-Reply-To: <1428933661-8193-2-git-send-email-pavlix@pavlix.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Apr 2015 16:00:56 +0200
Pavel =C5=A0imerda <pavlix@pavlix.net> wrote:

> From: Pavel =C5=A0imerda <psimerda@redhat.com>
>=20
> Changes:
>=20
>  * Accept directory settings from environment.
>  * Remove redundant ROOTDIR variable.
>  * Set KERNEL_INCLUDE default to '/usr/include'.
>  * Use CFLAGS from environemnt.
>=20
> Note: In the long term it might be better to improve the configure
> script to generate those parts of the Makefile in a manner similar
> to autoconf. It might be even practical to autotoolize the package.
>=20
> Signed-off-by: Pavel =C5=A0imerda <psimerda@redhat.com>

I will take this part.
But don't want to start iproute2 down the autoconf/autotool sink hole.
