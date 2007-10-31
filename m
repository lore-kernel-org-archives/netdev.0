From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [possibly OT] for_each_netdev() in 2.6.23-gitX /
 2.6.24-rc1-gitY breaks Cisco VPN client
Date: Tue, 30 Oct 2007 22:05:49 -0700
Message-ID: <20071030220549.7c312912@freepuppy.rosehill>
References: <5a4c581d0710301735h1682a30bvfbee632c118556d8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Alessandro Suardi" <alessandro.suardi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43606 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752751AbXJaFGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 01:06:33 -0400
In-Reply-To: <5a4c581d0710301735h1682a30bvfbee632c118556d8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Oct 2007 01:35:47 +0100
"Alessandro Suardi" <alessandro.suardi@gmail.com> wrote:

> It's been a while I noticed, but I thought someone would as usual
>  cook up some fix, while I don't even see the issue been reported...
>  if this isn't a Linux kernel/net issue just drop my email, thanks.
> 
> Error message during cisco_vpn.ko build:
> 
> /download/linux/net/vpnclient/interceptor.c:345:23: error: macro
> "for_each_netdev" requires 2 arguments, but only 1 given
> 

RTFM Documentation/stable_api_nonsense.txt


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
