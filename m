From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ravb: add R8A7791 support
Date: Mon, 30 Nov 2015 00:14:21 +0300
Message-ID: <565B6AAD.8080205@cogentembedded.com>
References: <6051623.qN4lqSyZKg@wasted.cogentembedded.com>
 <CAMuHMdWE_G2WqsGZEaa4Ck3zziTLGVPfaVdU2gbnLA5zWpmR1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:36268 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277AbbK2VOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 16:14:22 -0500
Received: by lfs39 with SMTP id 39so172721531lfs.3
        for <netdev@vger.kernel.org>; Sun, 29 Nov 2015 13:14:20 -0800 (PST)
In-Reply-To: <CAMuHMdWE_G2WqsGZEaa4Ck3zziTLGVPfaVdU2gbnLA5zWpmR1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/29/2015 10:26 PM, Geert Uytterhoeven wrote:

>> Add support  for yet another ARM member of the R-Car family, R-Car M2, also

> R-Car M2-W?

    Right, forgot about the postfixes.

>> known as R8A7791.
>
> There's also R-Car M2-N, aka R8A7793, but you probably know that ;-)

    Will fix.

> Gr{oetje,eeting}s,
>
>                          Geert

MBR, Sergei
