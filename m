From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: gro: remove obsolete code from
 skb_gro_receive()
Date: Fri, 06 Mar 2015 15:56:50 -0800
Message-ID: <1425686210.18614.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425592068.5130.266.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150306.010441.1755035570297062470.davem@davemloft.net>
	 <1425674388.18614.0.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150306.155932.2228013423238139112.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:45116 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752859AbbCFX4w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 18:56:52 -0500
Received: by igjz20 with SMTP id z20so8075797igj.4
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 15:56:51 -0800 (PST)
In-Reply-To: <20150306.155932.2228013423238139112.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-03-06 at 15:59 -0500, David Miller wrote:

> I left changes on my workstation at home before going to the office today,
> will fix things up tonight.
> 
> I suggested to Daniel, also effect by this brain-o, that I should setup
> my workstations to deliver an electric shock to me if I leave unpushed
> GIT changes around.

Ah OK, thanks David, no worries ;)
