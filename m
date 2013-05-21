From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 2/2] fec: Remove <linux/fec.h> header file
Date: Tue, 21 May 2013 13:02:56 -0300
Message-ID: <CAOMZO5CJbfssCzHoN5EwgNac-qBgZPjWgcxR4_VWc-hBxrJ=zQ@mail.gmail.com>
References: <1369151067-5220-1-git-send-email-fabio.estevam@freescale.com>
	<1369151067-5220-2-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Fabio Estevam <fabio.estevam@freescale.com>, shawn.guo@linaro.org,
	netdev@vger.kernel.org, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f44.google.com ([209.85.212.44]:62757 "EHLO
	mail-vb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754456Ab3EUQC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 12:02:57 -0400
Received: by mail-vb0-f44.google.com with SMTP id e13so556885vbg.3
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 09:02:56 -0700 (PDT)
In-Reply-To: <1369151067-5220-2-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 21, 2013 at 12:44 PM, Fabio Estevam
<fabio.estevam@freescale.com> wrote:
> There is no need to have a header file to hold a single structure.
>
> Move the 'fec_platform_data' structure definition into the local "fec.h" file
> and get rid of <linux/fec.h> header.

Please discard this one. It will cause issues on Coldfire.
