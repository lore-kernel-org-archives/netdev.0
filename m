From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] iproute2 : fix to catchup with xtables/iptables >=
	1.4.2
Date: Sat, 07 Feb 2009 11:14:59 -0500
Message-ID: <1234023299.4441.16.camel@dogo.mojatatu.com>
References: <1234015013.4441.4.camel@dogo.mojatatu.com>
	 <alpine.LSU.2.00.0902071543010.4534@fbirervta.pbzchgretzou.qr>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Andreas Henriksson <andreas@fatal.se>,
	Yevgeny Kosarzhevsky <yevg@pisem.net>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	Patrick McHardy <kaber@trash.net>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:52213 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752825AbZBGQQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 11:16:50 -0500
Received: by ewy14 with SMTP id 14so1860770ewy.13
        for <netdev@vger.kernel.org>; Sat, 07 Feb 2009 08:16:48 -0800 (PST)
In-Reply-To: <alpine.LSU.2.00.0902071543010.4534@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-02-07 at 15:43 +0100, Jan Engelhardt wrote:

> What about the proposed symbol rename in libxtables,
> would not it invalidate the patch?

The rename would be for post iptables 1.4.2.
We have a problem right now with distros already 
deploying iptables 1.4.2. This patch resolves that.

cheers,
jamal

