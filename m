From: Richard Weinberger <richard.weinberger@gmail.com>
Subject: Re: critic on documentation of the network stack
Date: Sun, 26 Jan 2014 11:35:13 +0100
Message-ID: <CAFLxGvxoYFB8davrvkXDUuqkBMHPwTRG6_Zn8xvkK_N3dSck-A@mail.gmail.com>
References: <20140124032324.GO7269@order.stressinduktion.org>
	<20140124155835.467deca8@nehalam.linuxnetplumber.net>
	<52E47E82.4040906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:45395 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712AbaAZKfO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 05:35:14 -0500
Received: by mail-ob0-f181.google.com with SMTP id va2so5344309obc.40
        for <netdev@vger.kernel.org>; Sun, 26 Jan 2014 02:35:14 -0800 (PST)
In-Reply-To: <52E47E82.4040906@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 26, 2014 at 4:18 AM, Florian Fainelli <f.fainelli@gmail.com=
> wrote:
> Le 24/01/2014 15:58, Stephen Hemminger a =E9crit :
>
>> On Fri, 24 Jan 2014 04:23:24 +0100
>> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
>>
>>> Hello!
>>>
>>> After net-next is closed I wanted to put the following link here:
>>>
>>>    <http://linux.slashdot.org/comments.pl?sid=3D4356053&cid=3D45184=
693>
>>
>>
>> The problem I have is more that there are more incorrect sources of
>> documentation
>> and differing opinions on the Internet. Maybe the problem is users, =
maybe
>> the
>> problem is lack of SEO, or developers not being paid to write
>> documentation, or
>> old web sites not being updated. For example, this commenter obvious=
ly
>> never
>> found http://www.lartc.org/
>
>
> (which unfortunately is rather outdated)

s/outdated/dead

> I do not buy the fact that some developers do not provide documentati=
on of
> the features they are adding potentially on purpose, truth is probabl=
y much
> simpler, you worked on X, you have now moved on and work on Y.

IMHO one cause of the problem is that many nice features get
implemented by contractors.
The customer is only interested in the kernel interface and has it's
own (proprietary) userland.
Don't get me wrong, this is perfectly fine.
But it has the side effect that a) the customer is not interested in
man-pages or other open docs/tools
(he does not want to reveal his magic sauce too early) and
b) the contractor is therefore not paid to provide docs.

> If nobody pays enough attention to what gets added through netdev, ip=
route2,
> ethtool, man-pages and enforces the need for documentation, then come=
s the
> current status quo where not all features are documented, until some
> benevolant person realizes this needs fixing. Considering the high vo=
lume of
> the list, this is all understandable.
>
> There could probably be some programmatical ways to enforce such
> documentation by only allowing patches coming with, say kernel-doc co=
ntent
> along the code, and have man-pages and other projects scan for new
> kernel-doc entries they have no reference for.
> --
> Florian
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



--=20
Thanks,
//richard
