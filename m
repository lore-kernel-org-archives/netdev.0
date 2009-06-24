From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: Any implementation of NETPOLL for bonding?
Date: Wed, 24 Jun 2009 12:34:40 -0400
Message-ID: <bdfc5d6e0906240934w18f80a1aq3075954326155b90@mail.gmail.com>
References: <1245101162.11148.210.camel@psmith-ubeta.netezza.com>
	 <20090615230907.GA8515@gospo.rdu.redhat.com>
	 <1245165201.11148.244.camel@psmith-ubeta.netezza.com>
	 <1245776460.9022.19.camel@psmith-ubeta.netezza.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: paul@mad-scientist.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f193.google.com ([209.85.221.193]:47421 "EHLO
	mail-qy0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760904AbZFXQkw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 12:40:52 -0400
Received: by qyk31 with SMTP id 31so1151276qyk.33
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 09:40:54 -0700 (PDT)
In-Reply-To: <1245776460.9022.19.camel@psmith-ubeta.netezza.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 23, 2009 at 1:01 PM, Paul Smith<paul@mad-scientist.us> wrot=
e:
> On Tue, 2009-06-16 at 11:13 -0400, Paul Smith wrote:
>> On Mon, 2009-06-15 at 19:09 -0400, Andy Gospodarek wrote:
>> > On Mon, Jun 15, 2009 at 05:26:02PM -0400, Paul Smith wrote:
>> > > I wanted to attach to my kernel with KGDBOE but failed because t=
he
>> > > bonding driver doesn't support NETPOLL, and the only network acc=
ess to
>> > > the system is over a bonded interface.
>> >
>> > I did some work in the not-too-distant past on this and can probab=
ly
>> > dig-up the patches and port them to the latest upstream. =A0Would =
you be
>> > able to test a patch?
>
> Hi Andy; did you have any time to dig these out and forward them to m=
e?
> I'm happy to test them for you.
>
> Thanks!
>
>

I did, but they are in rough shape right now since they are so old
(they don't apply at all).

I should be able to get them compiling and running by the end of the da=
y today.
