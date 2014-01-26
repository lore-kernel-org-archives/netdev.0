From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: critic on documentation of the network stack
Date: Sat, 25 Jan 2014 19:18:26 -0800
Message-ID: <52E47E82.4040906@gmail.com>
References: <20140124032324.GO7269@order.stressinduktion.org> <20140124155835.467deca8@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:57900 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbaAZDR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jan 2014 22:17:26 -0500
Received: by mail-ob0-f170.google.com with SMTP id va2so5244695obc.29
        for <netdev@vger.kernel.org>; Sat, 25 Jan 2014 19:17:25 -0800 (PST)
In-Reply-To: <20140124155835.467deca8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/01/2014 15:58, Stephen Hemminger a =E9crit :
> On Fri, 24 Jan 2014 04:23:24 +0100
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
>
>> Hello!
>>
>> After net-next is closed I wanted to put the following link here:
>>
>>    <http://linux.slashdot.org/comments.pl?sid=3D4356053&cid=3D451846=
93>
>
> The problem I have is more that there are more incorrect sources of d=
ocumentation
> and differing opinions on the Internet. Maybe the problem is users, m=
aybe the
> problem is lack of SEO, or developers not being paid to write documen=
tation, or
> old web sites not being updated. For example, this commenter obviousl=
y never
> found http://www.lartc.org/

(which unfortunately is rather outdated)

I do not buy the fact that some developers do not provide documentation=
=20
of the features they are adding potentially on purpose, truth is=20
probably much simpler, you worked on X, you have now moved on and work =
on Y.

If nobody pays enough attention to what gets added through netdev,=20
iproute2, ethtool, man-pages and enforces the need for documentation,=20
then comes the current status quo where not all features are documented=
,=20
until some benevolant person realizes this needs fixing. Considering th=
e=20
high volume of the list, this is all understandable.

There could probably be some programmatical ways to enforce such=20
documentation by only allowing patches coming with, say kernel-doc=20
content along the code, and have man-pages and other projects scan for=20
new kernel-doc entries they have no reference for.
--
=46lorian
