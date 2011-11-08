From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 3/6] [6LoWPAN] set proper netdev flags
Date: Tue, 8 Nov 2011 18:42:53 +0400
Message-ID: <CALT56yMAnC8Wy_tJWnWO2sLj68hnZQMoXN7sbH0-KeHt0daMxg@mail.gmail.com>
References: <20111102162520.GA2669@avtobot.cybertron>
	<1320251688-2859-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:42672 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab1KHOmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 09:42:53 -0500
Received: by pzk2 with SMTP id 2so1628166pzk.1
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 06:42:53 -0800 (PST)
In-Reply-To: <1320251688-2859-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/2/11, Alexander Smirnov <alex.bluesman.smirnov@gmail.com> wrote:
> This patch fixes settings for device initialization which makes possible to
> use NDISC and TCP.
>
> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>

Acked-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>

-- 
With best wishes
Dmitry
