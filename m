From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: race in skb_splice_bits?
Date: Tue, 27 May 2008 17:21:48 +0400
Message-ID: <20080527132148.GA7368@2ka.mipt.ru>
References: <200805270325.24323.opurdila@ixiacom.com> <20080527115206.GA30353@2ka.mipt.ru> <20080527115638.GB30353@2ka.mipt.ru> <200805271553.50001.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:55315 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757326AbYE0NWG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 09:22:06 -0400
Content-Disposition: inline
In-Reply-To: <200805271553.50001.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 27, 2008 at 03:53:49PM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> When you interrupt the program, the system will crash.

Cool!

I've reproduced the problem and will try to work it out, thank you.

-- 
	Evgeniy Polyakov
