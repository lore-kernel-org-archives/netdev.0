From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH net-next-2.6] TCP: de-bloat a bit with factoring NET_INC_STATS_BH
 out
Date: Thu, 26 Jun 2008 11:52:37 +0400
Message-ID: <48634AC5.20203@openvz.org>
References: <485931B5.2020509@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52897 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750874AbYFZHzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2008 03:55:11 -0400
In-Reply-To: <485931B5.2020509@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> There are some places in TCP that select one MIB index to
> bump snmp statistics like this:
> ...

Hello, David!

I suppose, that you're busy now with upcoming 2.6.26 release and
have little time to answer, but can you briefly tell me about your
plans about this patch?

The thing is that I'm now almost finished with the MIB netnsization
patch-set to send for discussion (and, frankly speaking, hopefully
for the inclusion in 2.6.27) and this work (slightly) depends on this
patch. And, since I mention, the MIBs - do I have any chance to
attract your attention to that set? :)

Thanks,
Pavel
