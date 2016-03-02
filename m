From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 1/2] net: ethernet: renesas: ravb_main: don't open code of_device_get_match_data()
Date: Wed, 2 Mar 2016 10:11:15 +0100
Message-ID: <CAMuHMdWti0SDibJX7+ZPzG7_i_i29kOyo1cqLG+d8R8k0dEx9w@mail.gmail.com>
References: <1456850284-8336-1-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-renesas-soc@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33778 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826AbcCBJLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 04:11:15 -0500
In-Reply-To: <1456850284-8336-1-git-send-email-wsa@the-dreams.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 5:37 PM, Wolfram Sang <wsa@the-dreams.de> wrote:
> From: Wolfram Sang <wsa+renesas@sang-engineering.com>
>
> This change will also make Coverity happy by avoiding a theoretical NULL
> pointer dereference; yet another reason is to use the above helper function
> to tighten the code and make it more readable.
>
> Signed-off-by: Wolfram Sang <wsa+renesas@sang-engineering.com>

Acked-by: Geert Uytterhoeven <geert+renesas@glider.be>

Gr{oetje,eeting}s,

                        Geert
