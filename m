From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] doc: make the description of how tcp_ecn
 works more explicit and clear
Date: Thu, 29 Nov 2012 10:42:01 -0800
Message-ID: <1354214521.3299.30.camel@edumazet-glaptop>
References: <20121128195310.C438D2900459@tardy>
	 <20121129.131627.987805831377793894.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: raj@tardy.usa.hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:52820 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752689Ab2K2SmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:42:04 -0500
Received: by mail-da0-f46.google.com with SMTP id p5so5378089dak.19
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 10:42:03 -0800 (PST)
In-Reply-To: <20121129.131627.987805831377793894.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 13:16 -0500, David Miller wrote:
> From: raj@tardy.usa.hp.com (Rick Jones)
> Date: Wed, 28 Nov 2012 11:53:10 -0800 (PST)
> 
> > From: Rick Jones <rick.jones2@hp.com>
> > 
> > Make the description of how tcp_ecn works a bit more explicit and clear.
> > 
> > Signed-off-by: Rick Jones <rick.jones2@hp.com>
> 
> Applied, thanks Rick.
> 
> I think we should change the default to one, to be honest.  I thought
> that's what we were doing by now...
> 
> '2' made sense 10 years ago, but it doesn't really today.

With 1 setting, I for example was enable to connect to a HP device,
when I was still working for SFR.

(It was an HTTP/HTTPS based administrative software, to manage HP c7000
enclosures)

I would suggest making a large scale experiment before doing this 2->1
move.
