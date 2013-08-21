From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: [PATCH v3] r8169: fix invalid register dump
Date: Wed, 21 Aug 2013 23:13:35 +0200
Message-ID: <4578926.BDvSIdbm2b@al>
References: <1376833298-7321-1-git-send-email-lekensteyn@gmail.com> <18365346.kxAWDne41Q@al> <20130821205325.GA24054@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	netdev@vger.kernel.org, nic_swsd@realtek.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:57287 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836Ab3HUVNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 17:13:40 -0400
Received: by mail-wg0-f45.google.com with SMTP id n12so879949wgh.12
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 14:13:38 -0700 (PDT)
In-Reply-To: <20130821205325.GA24054@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 21 August 2013 22:53:25 Francois Romieu wrote:
> Peter Wu <lekensteyn@gmail.com> :
> [...]
> 
> > Please find the updated patch below. There may be differences in lines
> > because net-next has the r8169,sis190 patch and net the WOL fix.
> > 
> > Can I consider Francois reply[1] as Acked-by?
> 
> Yes, provided you insert an empty line between declarations and code.
Done, new patch will arrive in a minute.

> You may / should send patches as normal submissions. It will probably
> be easier for davem to use and you can always raise questions or add
> minor remarks in the "--- ... diff" section.

I noticed that patchwork also recognized submissions that are appended to a 
mail, so I tried that out ;-) Well, apparantly it does not work well with git, 
so I will just send a new patch with a useful In-Reply-To header.

Peter
