From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] iproute2 : fix to catchup with xtables/iptables >=
	1.4.2
Date: Mon, 26 Jan 2009 08:47:20 -0500
Message-ID: <1232977640.13279.41.camel@dogo.mojatatu.com>
References: <1232908352.13279.33.camel@dogo.mojatatu.com>
	 <497DB9CF.6060408@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Andreas Henriksson <andreas@fatal.se>,
	Yevgeny Kosarzhevsky <yevg@pisem.net>,
	Jan Engelhardt <jengelh@medozas.de>,
	Denys Fedoryschenko <denys@visp.net.lb>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:35778 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbZAZNzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 08:55:37 -0500
Received: by ewy14 with SMTP id 14so462880ewy.13
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2009 05:55:35 -0800 (PST)
In-Reply-To: <497DB9CF.6060408@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-01-26 at 14:25 +0100, Patrick McHardy wrote:

> libxtables.so is pretty incomplete, the best thing would be if you'd
> move everything you need there so we can avoid any breakage in the
> future.

I am willing to send patches for libxtables - unless you guys are
already planning or working on things. It would be nice to have a
sync finally.

cheers,
jamal

