From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: Re: Contributing for the first time
Date: Mon, 7 Nov 2011 15:17:38 +0200
Message-ID: <CAEnQRZA=dwt6TjcBacYaj0ORdi5QjBEXUaPA4GT2tm2oE_LFew@mail.gmail.com>
References: <CAPhGq=b_DwhbChAm3HPfzTXedRM6qVvVW7an5YkM8hqwhgCjbA@mail.gmail.com>
	<4a08f8c6-d02e-40c4-b976-5437270ba5b2@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kernelnewbies@kernelnewbies.org, shemminger@vyatta.com,
	Greg Freemyer <greg.freemyer@gmail.com>, netdev@vger.kernel.org
To: Alexandru Juncu <alex.juncu@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:49177 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755500Ab1KGNRj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 08:17:39 -0500
Received: by qyk27 with SMTP id 27so2327206qyk.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 05:17:38 -0800 (PST)
In-Reply-To: <4a08f8c6-d02e-40c4-b976-5437270ba5b2@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 7, 2011 at 3:05 PM, Greg Freemyer <greg.freemyer@gmail.com>=
 wrote:
> Alexandru Juncu <alex.juncu@rosedu.org> wrote:
>
>>Hello!
>>
>>I have been a linux user for many years, and mostly on the networking
>>side. And I would like to start contributing somehow to the linux
>>community (in some other way than just promoting it). I guess that =A0=
I
>>should start small with something like man pages.
>>
>>And there is something that really has been bugging me for some time.
>>I'm an iproute2 user and I teach linux courses and show people how to
>>use it. On most questions from my students about new commands, I
>>redirect them to the man pages and to the Examples section of that
>>page. iproute2 doesn't have such examples and I always wish it did.
>>
>>Do you think that if I submit a patch to the man pages, adding some
>>examples of how to use the ip command, will it get accepted? Because
>>this sounds like a simple thing and it's hard to believe that someone
>>else didn't try do to this before. What do you think?
>>Alexandru Juncu

> I think it will be accepted, but few people like to work on the man p=
ages.
>
> Since this is a userspace package you will need to figure out who the=
 maintainer is and if there is a mailinglist they use to discuss/suppor=
t the package.
>
> Then submit your patch there.

According to [1] maintainer for iproute2 is Stephen Hemminger (CC'ed) a=
nd I
think patches should be sent to netdev mailing list ([2]).

thanks,
Daniel.

[1] http://www.linuxfoundation.org/collaborate/workgroups/networking/ip=
route2
[2] http://vger.kernel.org/vger-lists.html#netdev
