From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] iproute2 : fix to catchup with xtables/iptables >=
 1.4.2
Date: Mon, 26 Jan 2009 15:27:53 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0901261526560.18834@fbirervta.pbzchgretzou.qr>
References: <1232908352.13279.33.camel@dogo.mojatatu.com>  <497DB9CF.6060408@trash.net> <1232977640.13279.41.camel@dogo.mojatatu.com>  <497DC07C.2090900@trash.net> <1232979705.13279.50.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, Andreas Henriksson <andreas@fatal.se>,
	Yevgeny Kosarzhevsky <yevg@pisem.net>,
	Denys Fedoryschenko <denys@visp.net.lb>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:36586 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018AbZAZO1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 09:27:55 -0500
In-Reply-To: <1232979705.13279.50.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 2009-01-26 15:21, jamal wrote:
>On Mon, 2009-01-26 at 14:54 +0100, Patrick McHardy wrote:
>
>> To me knowledge, nobody is currently working on that.
>
>Ok - then i will grab the token. 
>The procedure i take it (no "submitting patches" section on
>netfilter.org) is use latest git tree, send patches to you + Jan.
>

What I wanted to do beforehand is give those functions a proper
prefix as it is ideally Supposed To Be^TM for libraries..
