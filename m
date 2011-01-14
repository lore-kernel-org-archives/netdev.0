From: Patrick McHardy <kaber@trash.net>
Subject: Re: sch_sfb
Date: Fri, 14 Jan 2011 14:37:44 +0100
Message-ID: <4D3051A8.6050305@trash.net>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>	<20101220232020.GB2052@del.dom.local>	<1292887689.2627.150.camel@edumazet-laptop>	<20101220235209.GA1865@del.dom.local>	<1292939574.6535.27.camel@mojatatu>	<AANLkTikwMQBwNdT1nZ97NNFYGJnwhk39+8afTKONgeF5@mail.gmail.com>	<20101221223704.GA1979@del.dom.local>	<1293111333.11306.170.camel@mojatatu>	<1294003631.2535.253.camel@edumazet-laptop>	<20110103095842.7677130d@nehalam>	<Pine.LNX.4.64.1101041506300.2576@ask.diku.dk>	<4D2EE708.8010806@trash.net> <87bp3kg58i.fsf_-_@trurl.pps.jussieu.fr>	<4D2F4B83.6060001@trash.net> <7ir5cgs3k1.fsf@lanthane.pps.jussieu.fr>	<4D2FA949.8020701@trash.net> <7ivd1rsj6n.fsf@lanthane.pps.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35457 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703Ab1ANNhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 08:37:42 -0500
In-Reply-To: <7ivd1rsj6n.fsf@lanthane.pps.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.01.2011 14:34, Juliusz Chroboczek wrote:
>> I just looked at it out of interest after already having started my
>> own version.
> 
>>>   http://thread.gmane.org/gmane.linux.network/90225
>>>   http://thread.gmane.org/gmane.linux.network/90375
> 
>>> It was reviewed in particular by one Patrick McHardy.
> 
>> There's no reason to be pissed
> 
> Yes, there is.
> 
> First you object to my patch by making a bunch of unreasonable requests
> (notably that I use the in-kernel classifiers, which are not usable with
> Bloom filters).

They are - at least the flow classifier and others returning numerical
classids. Which is the one most useful for SFB.

> Then it turns out you're implementing your own version
> "from scratch".  And then you claim that you never saw my version in the
> first place?

I said I didn't remember reviewing it. If you read my first email,
I specifically stated that I had a look at your version and noticed
a few bugs,

> Patrick, what you're doing is not merely rude, it's actually unethical.

I'm not continuing this discussion.
