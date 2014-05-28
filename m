From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v2 2/2] sfc: Restrict PIO to 64-bit architectures
Date: Wed, 28 May 2014 18:45:08 +0400
Message-ID: <5385F674.60504@cogentembedded.com>
References: <cover.1401268725.git.sshah@solarflare.com> <5385AC57.9040000@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com
To: Shradha Shah <sshah@solarflare.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:44213 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752909AbaE1OpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 10:45:04 -0400
Received: by mail-lb0-f175.google.com with SMTP id l4so5892773lbv.20
        for <netdev@vger.kernel.org>; Wed, 28 May 2014 07:45:02 -0700 (PDT)
In-Reply-To: <5385AC57.9040000@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/28/2014 01:28 PM, Shradha Shah wrote:

> From: Jon Cooper <jcooper@solarflare.com>

> Enable PIO for x86_64 architecture only.
> Not tested on platforms other than x86_64.

> Fixes:ee45fd92c739db5b7950163d91dfe5f016af6d24

    12 digits is enough. And please specify that commit's summary enclosed in 
parens and quotes.

> orig-hg-hash: 53dc43553d9bbe1c5a64c49e580ca571ddc470ae
> Signed-off-by: Shradha Shah <sshah@solarflare.com>
> ---
>   drivers/net/ethernet/sfc/io.h | 8 ++++++++
>   1 file changed, 8 insertions(+)

WBR, Sergei
