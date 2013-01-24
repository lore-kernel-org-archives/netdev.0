From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] via-rhine: add 64bit statistics.
Date: Wed, 23 Jan 2013 21:35:41 -0800
Message-ID: <1359005741.12374.1589.camel@edumazet-glaptop>
References: <5100b2f8.1883650a.37e6.17b4@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jamie Gloudon <jamie.gloudon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33819 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709Ab3AXFfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 00:35:44 -0500
Received: by mail-pa0-f50.google.com with SMTP id hz10so5272191pad.37
        for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 21:35:44 -0800 (PST)
In-Reply-To: <5100b2f8.1883650a.37e6.17b4@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-24 at 00:05 -0400, Jamie Gloudon wrote:
> Switch to use ndo_get_stats64 to get 64bit statistics.
> 
> Signed-off-by: Jamie Gloudon <jamie.gloudon@gmail.com>
> Tested-by: Jamie Gloudon <jamie.gloudon@gmail.com> 
> ---
>  drivers/net/ethernet/via/via-rhine.c | 47 ++++++++++++++++++++++++++++++------
>  1 file changed, 39 insertions(+), 8 deletions(-)

Acked-by: Eric Dumazet <edumazet@google.com>
