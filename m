From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: What queues/buffers does tc-netem use?
Date: Thu, 16 Jul 2015 15:04:19 +0200 (CEST)
Message-ID: <1880864426.2770.1437051859540.JavaMail.open-xchange@ox1app>
References: <ed5152b6a0e746b08b00c2dc8270afbc@ustx2ex-dag1mb3.msg.corp.akamai.com>,<116464048.2486.1437050567469.JavaMail.open-xchange@ox1app> <1437050912759.32788@akamai.com>
Reply-To: Hagen Paul Pfeifer <hagen@jauu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netem@osdl.org
To: netdev@vger.kernel.org, "Motejlek, Petr" <pmotejle@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mailbox.org ([80.241.60.215]:55819 "EHLO mx2.mailbox.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751345AbbGPNEX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2015 09:04:23 -0400
In-Reply-To: <1437050912759.32788@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On July 16, 2015 at 2:48 PM "Motejlek, Petr" <pmotejle@akamai.com>
> wrote:
>
> Could you please give me some example of such a tc command that
> would tell me the statistics? I am not sure what you mean.

tc -s qdisc show dev eth0

> Is there a way I can manipulate the internal rbtree queue size, please?

Sure, the option is called limit.
 
> Thank you

You are welcome!

Hagen
