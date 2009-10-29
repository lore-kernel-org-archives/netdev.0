From: Bob Beers <bob.beers@gmail.com>
Subject: Re: wanPMC-CxT1E1
Date: Wed, 28 Oct 2009 21:43:44 -0400
Message-ID: <4f6ba3b0910281843p73ef31bdm54b4640c21dbffbc@mail.gmail.com>
References: <4f6ba3b0910261322j273c977fm356506c46f095832@mail.gmail.com>
	 <20091026204144.GA28436@kroah.com>
	 <4f6ba3b0910271048n10ff37fek9af191b133892e1e@mail.gmail.com>
	 <20091029010535.GA18723@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f208.google.com ([209.85.219.208]:37193 "EHLO
	mail-ew0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754655AbZJ2Bnk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 21:43:40 -0400
Received: by ewy4 with SMTP id 4so1373801ewy.37
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2009 18:43:44 -0700 (PDT)
In-Reply-To: <20091029010535.GA18723@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 28, 2009 at 9:05 PM, Greg KH <greg@kroah.com> wrote:
> On Tue, Oct 27, 2009 at 01:48:53PM -0400, Bob Beers wrote:
>> On Mon, Oct 26, 2009 at 4:41 PM, Greg KH <greg@kroah.com> wrote:
>> > Getting it to build on 2.6.31 is more important than RHEL5, we can=
't do
>> > anything with an old kernel like that.
>>
>> ok, so where do I start, I have a system ready to start
>> =A0git cloning, and creating patches. I googled for a while
>> =A0but didn't find a nice recipe for participating in the -staging
>> =A0process.
>
> Ick, this isn't going to be easy, a lot of work needs to be done on t=
he
> driver to get it just to build on the latest kernel tree. =A0I person=
ally
> don't have the time to do it right now, but will gladly accept patche=
s
> that add it to the staging tree if someone else wants to do it.
>
> sorry,

I've started down the path.  Is 'successfully compiles' the only requir=
ement
 for the first patch?

thanks,
--=20
-Bob Beers
