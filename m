From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: tcp_release_cb() should release socket ownership
Date: Wed, 05 Mar 2014 18:20:51 -0800
Message-ID: <1394072451.27473.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393972752.26794.145.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140305.205938.287751582220842351.davem@davemloft.net>
	 <1394071601.27473.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140305.211530.2206817902037251680.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:37193 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756472AbaCFCVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 21:21:00 -0500
Received: by mail-pb0-f52.google.com with SMTP id rr13so1922434pbb.39
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 18:20:59 -0800 (PST)
In-Reply-To: <20140305.211530.2206817902037251680.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-03-05 at 21:15 -0500, David Miller wrote:

> Targetting net-next for the assertion is fine.
> 
> Did you get test results back yet?

Lars gave the results this morning for the first patch.

He said he was now testing the official patch.

Lets wait a bit more ;)
