From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [net-next PATCH v2 01/12] net: flow_table: create interface for
 hw match/action tables
Date: Mon, 19 Jan 2015 14:09:39 +0900
Message-ID: <20150119050937.GD5612@vergenet.net>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
 <20150113213529.13874.16858.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, sfeldma@gmail.com, netdev@vger.kernel.org,
	gerlitz.or@gmail.com, jhs@mojatatu.com, andy@greyhouse.net,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:53299 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbbASFJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 00:09:51 -0500
Received: by mail-pa0-f41.google.com with SMTP id rd3so36427566pab.0
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 21:09:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150113213529.13874.16858.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[snip]

> --- /dev/null
> +++ b/net/core/flow_table.c
> @@ -0,0 +1,942 @@
> +/*
> + * include/uapi/linux/if_flow.h - Flow table interface for Switch devices

Hi John,

its seems that the path in the above comment should be
net/core/flow_table.c.

[snip]
