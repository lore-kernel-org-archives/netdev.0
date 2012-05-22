From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Tue, 22 May 2012 11:25:59 +0200
Message-ID: <1337678759.3361.147.camel@edumazet-glaptop>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
	 <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
	 <1337099641.8512.1102.camel@edumazet-glaptop>
	 <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <1337101280.8512.1108.camel@edumazet-glaptop>
	 <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>
	 <1337272654.3403.20.camel@edumazet-glaptop>
	 <1337674831.1698.7.camel@kjm-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40064 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757034Ab2EVJ0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 05:26:04 -0400
Received: by bkcji2 with SMTP id ji2so4749493bkc.19
        for <netdev@vger.kernel.org>; Tue, 22 May 2012 02:26:02 -0700 (PDT)
In-Reply-To: <1337674831.1698.7.camel@kjm-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-22 at 09:20 +0100, Kieran Mansley wrote:
> On Thu, 2012-05-17 at 18:37 +0200, Eric Dumazet wrote:
> > 
> > With net-next and tcp coalescing, I no longer have TCPBacklogDrops /
> > collapses, but I dont have sfc card/driver.
> 
> I can still reproduce them on net-next.
> 
> Kieran

Can you reproduce this with tg3 NIC for example ?
