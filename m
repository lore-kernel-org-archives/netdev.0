From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] iproute2 : fix to catchup with xtables/iptables >=	1.4.2
Date: Mon, 26 Jan 2009 14:54:04 +0100
Message-ID: <497DC07C.2090900@trash.net>
References: <1232908352.13279.33.camel@dogo.mojatatu.com>	 <497DB9CF.6060408@trash.net> <1232977640.13279.41.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	Andreas Henriksson <andreas@fatal.se>,
	Yevgeny Kosarzhevsky <yevg@pisem.net>,
	Jan Engelhardt <jengelh@medozas.de>,
	Denys Fedoryschenko <denys@visp.net.lb>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44396 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbZAZNyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 08:54:08 -0500
In-Reply-To: <1232977640.13279.41.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Mon, 2009-01-26 at 14:25 +0100, Patrick McHardy wrote:
> 
>> libxtables.so is pretty incomplete, the best thing would be if you'd
>> move everything you need there so we can avoid any breakage in the
>> future.
> 
> I am willing to send patches for libxtables - unless you guys are
> already planning or working on things. It would be nice to have a
> sync finally.

To me knowledge, nobody is currently working on that.
