From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] iproute2 : fix to catchup with xtables/iptables >=
 1.4.2
Date: Sat, 7 Feb 2009 15:43:21 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0902071543010.4534@fbirervta.pbzchgretzou.qr>
References: <1234015013.4441.4.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Andreas Henriksson <andreas@fatal.se>,
	Yevgeny Kosarzhevsky <yevg@pisem.net>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	Patrick McHardy <kaber@trash.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:40595 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751986AbZBGOnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 09:43:24 -0500
In-Reply-To: <1234015013.4441.4.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Saturday 2009-02-07 14:56, jamal wrote:
>
>Against this morning's git tree (small compile fix in some
>environments).

What about the proposed symbol rename in libxtables,
would not it invalidate the patch?

>Please apply this one instead of previous one i posted last week.
>This is needed for users of tc ipt using iptables >= 1.4.2 such
>as current debian releases.
