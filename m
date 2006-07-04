From: jamal <hadi@cyberus.ca>
Subject: Re: [IPROUTE]: Introduce tc monitor
Date: Tue, 04 Jul 2006 09:15:41 -0400
Message-ID: <1152018941.5214.23.camel@jzny2>
References: <1151860849.5093.259.camel@jzny2>  <44A8EDE1.7030503@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:52443 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750775AbWGDNP7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 09:15:59 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Fxkkn-0008WU-BT
	for netdev@vger.kernel.org; Tue, 04 Jul 2006 09:15:49 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44A8EDE1.7030503@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-03-07 at 12:13 +0200, Patrick McHardy wrote:
> Speaking of actions, do you have any plans to
> add help-texts? Currently the output is very confusing, whenever
> I use them I need to google for examples.
> 

Thanks for reminding me. There are examples in the doc/ directory of
iproute2, but they may be insufficient.
In any case, I wont have time today or the rest of the week but will get
some patch after that. 

[Actually, I have about half a day off but I want to spend time
reviewing the qdisc_is_running thing in a test environment( It takes me
at least 2 hours to steal hardware and set it up)].

cheers,
jamal

