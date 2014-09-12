From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next v2] net: filter: constify detection of pkt_type_offset
Date: Fri, 12 Sep 2014 10:47:54 -0700
Message-ID: <CAHA+R7N9voYjoWGyOvfR35mNc3bK_ZMO8X9OAp6Cy7uZr3E-Fw@mail.gmail.com>
References: <5412D9B9.2020300@redhat.com>
	<3e68956a7e5b8bb9de226bfcc09092c6852a0a0a.1410523297.git.hannes@stressinduktion.org>
	<20140912160559.GA34038@its-macbook-pro.westell.com>
	<CAHA+R7NgqNSkcffcOWr9t6OqjTvfnrLZJdicpwYY91EWNZxyZA@mail.gmail.com>
	<1410541788.2970.2.camel@localhost>
	<CAHA+R7PrM3EwqD_7nT8odoCqmk7Q8cCdEcUn9Ck0MVPZKW3VXw@mail.gmail.com>
	<1410542240.2970.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Denis Kirjanov <kda@linux-powerpc.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:58822 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbaILRrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 13:47:55 -0400
Received: by mail-lb0-f175.google.com with SMTP id v6so1332609lbi.20
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 10:47:54 -0700 (PDT)
In-Reply-To: <1410542240.2970.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2014 at 10:17 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Fr, 2014-09-12 at 10:12 -0700, Cong Wang wrote:
>> On Fri, Sep 12, 2014 at 10:09 AM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>> >
>> > Sure, he asked me to send it and I included his signed-off. I think I
>> > did that correctly?
>> >
>>
>> Maybe you should add v3 in case people like me get confused. :)
>
> Oh, sorry. I looked in patchworks for the next version number and missed
> the v2 submission. My bad, this should be submission v3. I think it is
> ok, since the other versions already went out of review state.
>

Don't worry, it is not a big deal at all, unless DaveM gets confused too.
