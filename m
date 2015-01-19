From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH iproute2 3/3] ss: Unify tcp stats output
Date: Mon, 19 Jan 2015 14:57:50 +0100
Message-ID: <CAPh34mdJ7mjzueaX2qakoT=ODbHDLm4k-K_3Eg__6+s7ydf4Gg@mail.gmail.com>
References: <1421613815-6635-1-git-send-email-vadim4j@gmail.com>
	<1421613815-6635-4-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:60498 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404AbbASN5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 08:57:52 -0500
Received: by mail-lb0-f181.google.com with SMTP id u14so18786291lbd.12
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 05:57:50 -0800 (PST)
In-Reply-To: <1421613815-6635-4-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18 January 2015 at 21:43, Vadim Kochan <vadim4j@gmail.com> wrote:

> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>  misc/ss.c | 362 +++++++++++++++++++++++++++++++++++++++-----------------------
>  1 file changed, 231 insertions(+), 131 deletions(-)

Hey Vadin,

your patch do *not* change the output format, right? ss output is
parsed by scripts and tools.

hgn
