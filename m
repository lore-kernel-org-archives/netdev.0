From: Andreas Schwab <schwab@linux-m68k.org>
Subject: Re: [IPV6]: ROUTE:read ifname in rt6_info_route()
Date: Fri, 17 Apr 2009 12:24:42 +0200
Message-ID: <m2ljpzwpat.fsf@igel.home>
References: <49E710E1.3060209@miraclelinux.com>
	<20090416.043800.171462037.davem@davemloft.net>
	<20090416083031.1cc24489@nehalam> <m2y6u07dh3.fsf@igel.home>
	<20090416102731.459f9558@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, ysugiura@miraclelinux.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:39707 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754872AbZDQKYr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 06:24:47 -0400
In-Reply-To: <20090416102731.459f9558@nehalam> (Stephen Hemminger's message of
	"Thu, 16 Apr 2009 10:27:31 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> writes:

> The issue is what happens if name is not null terminated.

That cannot happen.  And a field width would not help anyway.

Andreas.

-- 
Andreas Schwab, schwab@linux-m68k.org
GPG Key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
