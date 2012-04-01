From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv6: RTM_GETROUTE inconsistent interpretation of RTA_IIF
Date: Sun, 01 Apr 2012 09:03:59 +0200
Message-ID: <1333263839.2325.4665.camel@edumazet-glaptop>
References: <20120329150311.51fe0e2d@pixies.home.jungo.com>
	 <20120401091807.2f4614f2@pixies.home.jungo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:49754 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903Ab2DAHEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 03:04:04 -0400
Received: by wgbdr13 with SMTP id dr13so1734101wgb.1
        for <netdev@vger.kernel.org>; Sun, 01 Apr 2012 00:04:03 -0700 (PDT)
In-Reply-To: <20120401091807.2f4614f2@pixies.home.jungo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-04-01 at 09:18 +0300, Shmulik Ladkani wrote:
> (Bump)
> 
> Any reason not to submit a patch that fixes the below issue?

Hi Shmulik

No reason I can think about. Are you planning to provide this yourself ?
