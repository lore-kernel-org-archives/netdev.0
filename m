From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/9] sfc: Increase size of RX SKB header area
Date: Tue, 16 Jul 2013 13:22:00 -0700
Message-ID: <1374006120.6097.6.camel@edumazet-glaptop>
References: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
	 <1372104801.1896.32.camel@bwh-desktop.uk.level5networks.com>
	 <1373996035.6097.5.camel@edumazet-glaptop>
	 <1373997228.2120.15.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:39185 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933572Ab3GPUWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jul 2013 16:22:03 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc8so1078124pbc.18
        for <netdev@vger.kernel.org>; Tue, 16 Jul 2013 13:22:01 -0700 (PDT)
In-Reply-To: <1373997228.2120.15.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-16 at 18:53 +0100, Ben Hutchings wrote:

> Perhaps, yes.  I also thought of using some of the other parser status
> from RX completions to estimate the length of headers.

That would be ideal indeed, I can provide a patch.
