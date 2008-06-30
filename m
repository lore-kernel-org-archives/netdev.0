From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 6/8] netfilter: fix string extension for case insensitive
 pattern matching
Date: Mon, 30 Jun 2008 22:04:31 +0200
Message-ID: <48693C4F.20408@trash.net>
References: <1214034858-1378-1-git-send-email-joonwpark81@gmail.com>	 <alpine.LNX.1.10.0806210957140.28924@fbirervta.pbzchgretzou.qr>	 <b25c3fa70806301144x4cd521dfpdd8bb6ef13b8466@mail.gmail.com>	 <alpine.LNX.1.10.0806302108290.30639@fbirervta.pbzchgretzou.qr> <b25c3fa70806301232w41617d02qa53292f5982c25d0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Engelhardt <jengelh@medozas.de>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45071 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751667AbYF3UEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 16:04:36 -0400
In-Reply-To: <b25c3fa70806301232w41617d02qa53292f5982c25d0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park wrote:
> 2008/6/30 Jan Engelhardt <jengelh@medozas.de>:
>> Right, since we copy eader files anyway, we can just make it uint8_t flags
>> without the union.
> 
> I like it :-)
> Patrick, Thomas, If you want I'll send this fix with version checking patch.

Yes, please also include the suggestions I made previously
that still apply (should be all of them).
