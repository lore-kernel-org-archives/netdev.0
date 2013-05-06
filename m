From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: PATCH iproute2] catch iptables interface changes
Date: Mon, 6 May 2013 19:23:52 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1305061923180.4028@nerf07.vanv.qr>
References: <517D35D6.8090606@mojatatu.com> <20130506165343.GA9077@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, shemminger@vyatta.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:33783 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753525Ab3EFRXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 May 2013 13:23:54 -0400
In-Reply-To: <20130506165343.GA9077@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Monday 2013-05-06 18:53, Pablo Neira Ayuso wrote:
>
>XTABLES_VERSION_CODE = libxtables_vcurrent - libxtables_vage
>
>iptables 1.4.19 -> 10
>iptables 1.4.18 -> 10
>iptables 1.4.17 -> 9
>iptables 1.4.16.3 -> 9
>[ seems like we have skip one by accident ]
>iptables 1.4.15 -> 7

No accident here. We had 7:0:0, 8:0:1, 9:0:2/9:0:0.
