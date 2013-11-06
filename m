From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] netfilter: ipvs: ip_vs_sync: Remove unused variable
Date: Wed, 6 Nov 2013 09:05:33 -0200
Message-ID: <CAOMZO5Bp4Pot26tZTEavAyW=4uTw=JBg1jExNQeiiyzGD6Z3BA@mail.gmail.com>
References: <1381180142-3388-1-git-send-email-festevam@gmail.com>
	<20131028010418.GJ849@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ja@ssi.bg, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f169.google.com ([209.85.128.169]:58657 "EHLO
	mail-ve0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932137Ab3KFLFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 06:05:34 -0500
Received: by mail-ve0-f169.google.com with SMTP id c14so3426100vea.14
        for <netdev@vger.kernel.org>; Wed, 06 Nov 2013 03:05:33 -0800 (PST)
In-Reply-To: <20131028010418.GJ849@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Simon,

On Sun, Oct 27, 2013 at 11:04 PM, Simon Horman <horms@verge.net.au> wrote:

> Hi Fabio,
>
> this patch does not seem to apply against ipvs-next.
> Could you please rework it and repost if you believe it is still needed.

Yes, ipvs-next does not have this issue, but linux-next still shows
this problem though.

Won't ipvs-next get synced with linux-next?

Regards,

Fabio Estevam
