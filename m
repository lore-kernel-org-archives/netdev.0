From: Richard Weinberger <richard.weinberger@gmail.com>
Subject: Re: What's the right way to use a *large* number of source addresses?
Date: Sat, 24 May 2014 16:44:03 +0200
Message-ID: <CAFLxGvx-6F3OqSBjSCBnm5b+m_NingSsbO2qaP7K7TtJghF5LQ@mail.gmail.com>
References: <6zlhtsvnqp.fsf@southpole.se>
	<53808957.7020906@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Niels_M=C3=B6ller?= <nisse@southpole.se>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jonas Bonn <jonas@southpole.se>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f177.google.com ([209.85.128.177]:44551 "EHLO
	mail-ve0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbaEXOoF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 10:44:05 -0400
Received: by mail-ve0-f177.google.com with SMTP id db11so7545322veb.36
        for <netdev@vger.kernel.org>; Sat, 24 May 2014 07:44:04 -0700 (PDT)
In-Reply-To: <53808957.7020906@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 24, 2014 at 1:58 PM, Jamal Hadi Salim <jhs@mojatatu.com> wr=
ote:
> On 05/23/14 05:38, Niels M=C3=B6ller wrote:
>>
>> Hi,
>>
>
>
>>     Main drawback of using NAT is the overhead for connection tracki=
ng;
>>     it would be preferable if the only per-connection state needed i=
s the
>>     socket itself.
>>
>
> If stateless nat is sufficient take a look at tc nat.

How to use this?
My tc's manpage does not know anything about nat.

Maybe I'm mistaken but IIRC all non-netfilter nat code has been removed=
=2E

--=20
Thanks,
//richard
