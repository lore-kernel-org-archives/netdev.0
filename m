From: Asi Lichtenstein <asili22@gmail.com>
Subject: Re: How to add IPv6 multiple routing tables support to 2.6.16.26 kernel
Date: Thu, 2 Jan 2014 22:06:41 +0200
Message-ID: <CAMBtn_3a48iiSetS=EyASDrJk_86Lt7hpt5ZN5NfEzUVYa6-Lg@mail.gmail.com>
References: <CAMBtn_2fjONQk0aO6MBy3j9X__78CTon_aYzJWCjouKnZDXEMw@mail.gmail.com>
	<1388687224.9947.25.camel@bwh-desktop.uk.level5networks.com>
	<CAMBtn_3OnZWZdSWHN3sg0jwG74mUWprNO+H9gE9tDgRO-j2f3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:43929 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398AbaABUGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 15:06:42 -0500
Received: by mail-oa0-f54.google.com with SMTP id h16so15289874oag.41
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 12:06:42 -0800 (PST)
In-Reply-To: <CAMBtn_3OnZWZdSWHN3sg0jwG74mUWprNO+H9gE9tDgRO-j2f3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks. I will take a look.
The problem is that I can't upgrade.
I know its too old but this is the one I'm stuck with.

Do you think I could find only the patch I'm looking for?

I just need that feature.

10x

On Thu, Jan 2, 2014 at 9:52 PM, Asi Lichtenstein <asili22@gmail.com> wrote:
> Thanks. I will take a look.
> The problem is that I can't upgrade.
> I know its too old but this is the one I'm stuck with.
>
> Do you think I could find only the patch I'm looking for?
>
> I just need that feature.
>
> 10x
>
> On Jan 2, 2014 8:27 PM, "Ben Hutchings" <bhutchings@solarflare.com> wrote:
>>
>> On Thu, 2014-01-02 at 15:24 +0200, Asi Lichtenstein wrote:
>> > Hi there,
>> >
>> > I need to add such support.
>> > How would you recommend me adding such support?
>> >
>> > Is there a patch I could use?
>>
>> There is a series of patches on ftp.kernel.org that you can use to
>> update from 2.6.16 to 3.12 or any version in between. :-)
>>
>> Seriously, this list does not deal with development on such old kernel
>> versions.
>>
>> Ben.
>>
>> --
>> Ben Hutchings, Staff Engineer, Solarflare
>> Not speaking for my employer; that's the marketing department's job.
>> They asked us to note that Solarflare product names are trademarked.
>>
>
