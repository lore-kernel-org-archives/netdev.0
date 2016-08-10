From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ravb: use proper names for suspend/resume functions
Date: Wed, 10 Aug 2016 14:16:58 +0300
Message-ID: <44ec3396-bd72-9f95-8c15-ae030efa4b64@cogentembedded.com>
References: <20160810110949.16608-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, wsa@the-dreams.de
To: =?UTF-8?Q?Niklas_S=c3=b6derlund?=
	<niklas.soderlund+renesas@ragnatech.se>, netdev@vger.kernel.org,
	linux-renesas-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:34938 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932828AbcHJShM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 14:37:12 -0400
Received: by mail-wm0-f54.google.com with SMTP id f65so106449778wmi.0
        for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 11:37:12 -0700 (PDT)
In-Reply-To: <20160810110949.16608-1-niklas.soderlund+renesas@ragnatech.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/10/2016 2:09 PM, Niklas Söderlund wrote:

> The patch 'ravb: add sleep PM suspend/resume support' used incorrect

    Actually, that patch should now have immutable SHA1 ID.

> function names containing 'runtime' for the suspend and resume
> functions.
>
> Reported-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
