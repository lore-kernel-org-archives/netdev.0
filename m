From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2] iplink: add support for num[tr]xqueues
Date: Fri, 20 Jul 2012 20:22:11 +0200
Message-ID: <20120720182211.GC1560@minipsycho.orion>
References: <s6ijrlvetpfdqgjl8x20788e.1342807975041@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	edumazet@google.com, shemminger@vyatta.com
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:60326 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab2GTSWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:22:15 -0400
Received: by weyx8 with SMTP id x8so2820721wey.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 11:22:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <s6ijrlvetpfdqgjl8x20788e.1342807975041@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jul 20, 2012 at 08:12:55PM CEST, stephen.hemminger@vyatta.com wrote:
>
>Or use matches("numtxqueues") rather than strcmp

Okay - I will repost with "matches"
