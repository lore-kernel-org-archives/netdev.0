From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [iproute2] tc: Show classes more hierarchically]
Date: Wed, 24 Dec 2014 15:59:57 +0200
Message-ID: <CAMw6YJK8OBCTNMF2xf3fa_Hnutxf6paEaVkfDKDJSbqUSPchKQ@mail.gmail.com>
References: <20141217115535.3f5198d2@urahara>
	<20141217235627.GA2149@angus-think.lan>
	<54923434.3030209@gmail.com>
	<20141218031257.GA19527@angus-think.lan>
	<5492C7FD.8060603@gmail.com>
	<20141218122329.GA31878@angus-think.lan>
	<5492CC8E.6050108@gmail.com>
	<20141218131653.GA5980@angus-think.lan>
	<5492DAFA.5070001@redhat.com>
	<20141218134621.GA9985@angus-think.lan>
	<20141218135848.GB16239@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:37295 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbaLXN76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 08:59:58 -0500
Received: by mail-wi0-f170.google.com with SMTP id bs8so15798627wib.3
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 05:59:57 -0800 (PST)
In-Reply-To: <20141218135848.GB16239@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2014 at 3:58 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 12/18/14 at 03:46pm, Vadim Kochan wrote:
>> On Thu, Dec 18, 2014 at 02:47:38PM +0100, Daniel Borkmann wrote:
>> > On 12/18/2014 02:16 PM, Vadim Kochan wrote:
>> > ...
>> > >The problem that this is huge now but looks better visually, I am
>> > >thinking also about to possibiliy to show only some part of tree by specified parent id ...
>> >
>> > I definitely like this work!
>> >
>> > Just thinking out loud, what about an output option for tc which is plain
>> > DOT [1], thus it can be handed over for rendering in tools like graphviz?
>> >
>> > It won't require any dependencies either as it's just plaintext.
>> >
>> >   [1] https://en.wikipedia.org/wiki/DOT_%28graph_description_language%29
>>
>> Yeah, good idea :-)
>
> tcng had something like that ;-)

I did not use tcng, but I think that it would be good to adopt some
useful features to the tc.

Regards,
