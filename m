From: Bob Beers <bob.beers@gmail.com>
Subject: Re: wanPMC-CxT1E1
Date: Mon, 26 Oct 2009 16:57:35 -0400
Message-ID: <4f6ba3b0910261357x2e5bdf5byb03b1debd177ec86@mail.gmail.com>
References: <4f6ba3b0910261322j273c977fm356506c46f095832@mail.gmail.com>
	 <20091026204144.GA28436@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f208.google.com ([209.85.219.208]:35502 "EHLO
	mail-ew0-f208.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbZJZU5c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 16:57:32 -0400
Received: by ewy4 with SMTP id 4so4033906ewy.37
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2009 13:57:36 -0700 (PDT)
In-Reply-To: <20091026204144.GA28436@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 26, 2009 at 4:41 PM, Greg KH <greg@kroah.com> wrote:
> On Mon, Oct 26, 2009 at 04:22:08PM -0400, Bob Beers wrote:
>> Hello List,
>>
>> I am using subject named card[1] and it has a GPL driver that is
>> =A0out-of-tree. =A0I have permission from the manufacturer to post a=
nd
>> =A0discuss it, so I'd like to get started. =A0Where/how shall I post=
 the code,
>> =A0and my first patch which allows it to compile and run with the
>> =A0kernel of RHEL/CentOS 5? =A0The tarball includes driver source an=
d
>> =A0a utility pmcc4cfg, and is 174 093 bytes.
>
> Getting it to build on 2.6.31 is more important than RHEL5, we can't =
do
> anything with an old kernel like that.
>

I know, but I'll need to back port it as soon as possible.

> Do you have a pointer to where we can download the tarball? =A0I'll b=
e
> glad to add it to the staging tree so it can be cleaned up there befo=
re
> being submitted to the main portion of the kernel tree.
>

<http://rapidshare.com/files/298314343/wanPMC_CxT1E1_Linux_3_1B.tgz.htm=
l>
MD5: 563FC98A1A0EA625F72C45B89E5C726B

> thanks,
>
> greg k-h
>

Thanks,

-Bob Beers
