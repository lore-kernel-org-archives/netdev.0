From: Patrick McHardy <kaber@trash.net>
Subject: Re: net: fix network drivers ndo_start_xmit() return values
Date: Tue, 16 Jun 2009 11:31:17 +0200
Message-ID: <4A376665.6000801@trash.net>
References: <4A367E14.4040104@trash.net> <20090616061603.GA4494@ff.dom.local> <20090616071204.GB4494@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, perex@perex.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34010 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbZFPJbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 05:31:16 -0400
In-Reply-To: <20090616071204.GB4494@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Tue, Jun 16, 2009 at 06:16:03AM +0000, Jarek Poplawski wrote:
>   
>> On 15-06-2009 19:00, Patrick McHardy wrote:
>>     
>>> This patch contains the final driver ndo_start_xmit() return
>>> value fixups. I'm pretty sure I got them all ...
>>>       
>
> ...You should probably revisit wireless/zd1201.c (return 0) btw.

Whats wrong with that?
