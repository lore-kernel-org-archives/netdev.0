From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [iproute2] tc: Show classes more hierarchically]
Date: Wed, 24 Dec 2014 10:07:34 -0500
Message-ID: <549AD6B6.9090509@mojatatu.com>
References: <20141217115535.3f5198d2@urahara>	<20141217235627.GA2149@angus-think.lan>	<54923434.3030209@gmail.com>	<20141218031257.GA19527@angus-think.lan>	<5492C7FD.8060603@gmail.com>	<20141218122329.GA31878@angus-think.lan>	<5492CC8E.6050108@gmail.com>	<20141218131653.GA5980@angus-think.lan>	<5492DAFA.5070001@redhat.com>	<20141218134621.GA9985@angus-think.lan>	<20141218135848.GB16239@casper.infradead.org> <CAMw6YJK8OBCTNMF2xf3fa_Hnutxf6paEaVkfDKDJSbqUSPchKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Werner Almesberger <werner@almesberger.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: Vadim Kochan <vadim4j@gmail.com>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:42639 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938AbaLXPHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 10:07:36 -0500
Received: by mail-ig0-f180.google.com with SMTP id h15so7099870igd.1
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 07:07:35 -0800 (PST)
In-Reply-To: <CAMw6YJK8OBCTNMF2xf3fa_Hnutxf6paEaVkfDKDJSbqUSPchKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/24/14 08:59, Vadim Kochan wrote:
> On Thu, Dec 18, 2014 at 3:58 PM, Thomas Graf <tgraf@suug.ch> wrote:
>> On 12/18/14 at 03:46pm, Vadim Kochan wrote:
>>> On Thu, Dec 18, 2014 at 02:47:38PM +0100, Daniel Borkmann wrote:
>>>> On 12/18/2014 02:16 PM, Vadim Kochan wrote:
>>>> ...
>>>>> The problem that this is huge now but looks better visually, I am
>>>>> thinking also about to possibiliy to show only some part of tree by specified parent id ...
>>>>
>>>> I definitely like this work!
>>>>
>>>> Just thinking out loud, what about an output option for tc which is plain
>>>> DOT [1], thus it can be handed over for rendering in tools like graphviz?
>>>>
>>>> It won't require any dependencies either as it's just plaintext.
>>>>
>>>>    [1] https://en.wikipedia.org/wiki/DOT_%28graph_description_language%29
>>>
>>> Yeah, good idea :-)
>>
>> tcng had something like that ;-)
>
> I did not use tcng, but I think that it would be good to adopt some
> useful features to the tc.
>

Werner unfortunately wont be able to make netdev01 ;-> but we could have
this discussion there.
For the record I am enjoying seeing these patches as well;->

cheers,
jamal
