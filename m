From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: ipv6: RTM_GETROUTE inconsistent interpretation of RTA_IIF
Date: Sun, 1 Apr 2012 10:28:53 +0300
Message-ID: <20120401102853.3f3901f6@pixies.home.jungo.com>
References: <20120329150311.51fe0e2d@pixies.home.jungo.com>
	<20120401091807.2f4614f2@pixies.home.jungo.com>
	<1333263839.2325.4665.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49850 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925Ab2DAH3E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 03:29:04 -0400
Received: by wejx9 with SMTP id x9so1118852wej.19
        for <netdev@vger.kernel.org>; Sun, 01 Apr 2012 00:29:02 -0700 (PDT)
In-Reply-To: <1333263839.2325.4665.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 01 Apr 2012 09:03:59 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sun, 2012-04-01 at 09:18 +0300, Shmulik Ladkani wrote:
> > (Bump)
> > 
> > Any reason not to submit a patch that fixes the below issue?
> 
> Hi Shmulik
> 
> No reason I can think about. Are you planning to provide this yourself ?

Yes.

Just wanted to make sure ipv6's RTA_IIF interpretation is not deliberate.

Regards,
Shmulik
