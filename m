From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: 4.1.0, kernel panic, =?UTF-8?Q?pppoe=5Frelease?=
Date: Fri, 25 Sep 2015 18:02:42 +0300
Message-ID: <3e1192bd3125fd5054c1417bce869505@visp.net.lb>
References: <677da51dbac367fcb7a456de2789334b@visp.net.lb>
 <c6e2cb4002bf11ad7a25be8eeded2dc1@visp.net.lb>
 <1437147400.5437.4.camel@redhat.com>
 <de4b28603ef7bcaea7aeca73dab80079@visp.net.lb>
 <20150910155657.GC3661@alphalink.fr>
 <9392178bf13d2814e19b1756cd204d73@visp.net.lb>
 <20150925143831.GI2869@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw@redhat.com>, Netdev <netdev@vger.kernel.org>,
	ebiederm@xmission.com, davem@davemloft.net, simon@farnz.org.uk,
	develop@kristov.de
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:33217 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754093AbbIYPCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 11:02:46 -0400
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id DFE08480644
	for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 18:02:43 +0300 (EEST)
In-Reply-To: <20150925143831.GI2869@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-09-25 17:38, Guillaume Nault wrote:
> On Tue, Sep 22, 2015 at 04:47:48AM +0300, Denys Fedoryshchenko wrote:
>> Hi,
>> Sorry for late reply, was not able to push new kernel on pppoes 
>> without
>> permissions (it's production servers), just got OK.
>> 
>> I am testing patch on another pppoe server with 9k users, for ~3 days, 
>> seems
>> fine. I will test today
>> also on server that was experiencing crashes within 1 day.
>> 
> Thanks for the feedback. I'm about to submit a fix. Should I add a
> Tested-by tag for you?
On one of servers i got same crash as before, within hours. 9k users 
server also crashed after while, so it seems it doesn't help.
I will do some more tests tomorrow.
