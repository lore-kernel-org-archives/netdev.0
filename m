From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next-2.6 4/4] bridge: implement [add/del]_slave ops
Date: Wed, 16 Feb 2011 05:21:54 -0800
Message-ID: <20110216052154.4e437265@s6510>
References: <20110213193105.GD2740@psychotron.redhat.com>
	<20110213193341.GG2740@psychotron.redhat.com>
	<20110213.165903.184824754.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, nicolas.2p.debian@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44336 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753160Ab1BPNV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Feb 2011 08:21:56 -0500
In-Reply-To: <20110213.165903.184824754.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Feb 2011 16:59:03 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Jiri Pirko <jpirko@redhat.com>
> Date: Sun, 13 Feb 2011 20:33:42 +0100
> 
> > add possibility to addif/delif via rtnetlink
> > 
> > Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> Applied.

You should follow established protocol and wait until I have
had time to review code that impacts areas which I maintain.
The linux-foundation email address is not listed in MAINTAINERS
file and is mainly a spam catcher that I never read.

Maybe I should just start sending networking patches to Linus.
