From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next PATCH v2 00/12] Flow API
Date: Wed, 14 Jan 2015 17:00:52 +0200
Message-ID: <CAJ3xEMgMSyRbfWFpFE0LVJtvXM20rEkjfvV6XztPa=Gxx_ZPEw@mail.gmail.com>
References: <20150113212941.13874.48692.stgit@nitbit.x32>
	<CAJ3xEMhSkHMTqvvaP2jS5Q8dh3FgqSt2JnQc+WuPeYwh0P5dkw@mail.gmail.com>
	<54B680EB.8040404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, simon.horman@netronome.com,
	Scott Feldman <sfeldma@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:44649 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbbANPAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 10:00:52 -0500
Received: by mail-ob0-f173.google.com with SMTP id nt9so8357326obb.4
        for <netdev@vger.kernel.org>; Wed, 14 Jan 2015 07:00:52 -0800 (PST)
In-Reply-To: <54B680EB.8040404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2015 at 4:44 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 01/13/2015 10:29 PM, Or Gerlitz wrote:
>>
>> On Tue, Jan 13, 2015 at 11:35 PM, John Fastabend
>> <john.fastabend@gmail.com> wrote:
>>>
>>> I tried to roll in all the feedback from v1 into this series annotated
>>> here,

>> Can you please drop V2 to your
>> https://github.com/jrfastab/rocker-net-next.git tree?

> Should be there now, but as Alexei noted I seem to have missed updating
> the patch commit messages so they still reference the old names.

Oh, I see it now.. yep, with the old names and dates to Dec 30th...
