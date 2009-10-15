From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [iproute2 PATCH] Add 'ip tuntap' support.
Date: Thu, 15 Oct 2009 09:56:57 +0100
Message-ID: <1255597017.12441.5.camel@macbook.infradead.org>
References: <1253378923.6317.11.camel@macbook.infradead.org>
	 <20090919125222.5f4718f1@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43063 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933118AbZJOI5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 04:57:35 -0400
In-Reply-To: <20090919125222.5f4718f1@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-09-19 at 12:52 -0700, Stephen Hemminger wrote:
> 
> I added it, but:
>   * cleaned up whitespace
>   * use if_tun.h from sanitized 2.6.30
>   * ifdef IFF_TUN_EXCL flag, so can build with older code
>    (currently iproute is releasing for 2.6.30) 

Where did you add it? I still don't see it in the repo at
git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

-- 
dwmw2

