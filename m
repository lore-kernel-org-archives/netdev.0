From: Kieran Mansley <kmansley@solarflare.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Tue, 22 May 2012 09:20:28 +0100
Message-ID: <1337674831.1698.7.camel@kjm-desktop.uk.level5networks.com>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
	 <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
	 <1337099641.8512.1102.camel@edumazet-glaptop>
	 <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <1337101280.8512.1108.camel@edumazet-glaptop>
	 <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>
	 <1337272654.3403.20.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:57520 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755928Ab2EVIUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 04:20:44 -0400
In-Reply-To: <1337272654.3403.20.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 18:37 +0200, Eric Dumazet wrote:
> 
> With net-next and tcp coalescing, I no longer have TCPBacklogDrops /
> collapses, but I dont have sfc card/driver.

I can still reproduce them on net-next.

Kieran
