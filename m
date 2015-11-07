From: Albino B Neto <bino@bino.us>
Subject: Re: [PATCH] man: Syntax and warning fixes
Date: Sat, 7 Nov 2015 07:47:58 -0200
Message-ID: <CAMu38xJwGcNgXKEZbuNFkEYDCtUoE1=xh6o3VziVOzwxdogkgg@mail.gmail.com>
References: <1446889471-22296-1-git-send-email-ville.skytta@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Ville_Skytt=C3=A4?= <ville.skytta@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway26.websitewelcome.com ([192.185.27.2]:46370 "EHLO
	gateway26.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751180AbbKGKeN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Nov 2015 05:34:13 -0500
Received: from ham06.websitewelcome.com (unknown [108.179.254.230])
	by gateway26.websitewelcome.com (Postfix) with ESMTP id E9B1ABF4BB88F
	for <netdev@vger.kernel.org>; Sat,  7 Nov 2015 03:47:59 -0600 (CST)
Received: from br538.hostgator.com.br (br538.hostgator.com.br [108.179.252.175])
	by ham06.websitewelcome.com (Postfix) with ESMTP id 5E0214000B
	for <netdev@vger.kernel.org>; Sat,  7 Nov 2015 03:47:59 -0600 (CST)
Received: from [209.85.220.182] (port=34528 helo=mail-qk0-f182.google.com)
	by br538.hostgator.com.br with esmtpsa (TLSv1.2:AES128-GCM-SHA256:128)
	(Exim 4.85)
	(envelope-from <bino@bino.us>)
	id 1Zv06I-0001MB-RQ
	for netdev@vger.kernel.org; Sat, 07 Nov 2015 03:47:58 -0600
Received: by qkcn129 with SMTP id n129so54417706qkc.1
        for <netdev@vger.kernel.org>; Sat, 07 Nov 2015 01:47:58 -0800 (PST)
In-Reply-To: <1446889471-22296-1-git-send-email-ville.skytta@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-11-07 7:44 GMT-02:00 Ville Skytt=C3=A4 <ville.skytta@iki.fi>:
> ---
>  man/man8/tc-bpf.8         | 2 +-
>  man/man8/tipc-bearer.8    | 4 ++--
>  man/man8/tipc-link.8      | 6 +++---
>  man/man8/tipc-media.8     | 4 ++--
>  man/man8/tipc-nametable.8 | 4 ++--
>  man/man8/tipc-node.8      | 4 ++--
>  man/man8/tipc-socket.8    | 4 ++--
>  7 files changed, 14 insertions(+), 14 deletions(-)
>
> diff --git a/man/man8/tc-bpf.8 b/man/man8/tc-bpf.8
> index 2c02ab2..f5201d3 100644
> --- a/man/man8/tc-bpf.8
> +++ b/man/man8/tc-bpf.8
> @@ -844,7 +844,7 @@ result in the default classid:
>  Basically, such a minimal generator is equivalent to:

Signed-off-by and description ?


           Albino
