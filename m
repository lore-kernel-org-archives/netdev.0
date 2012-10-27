From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: Information about napi_struct and net_device
Date: Sat, 27 Oct 2012 22:10:46 +0200
Message-ID: <CAKoUArkkfTe96yQTSNsXsp=KBJ7QtOqoKRz=0WaprKe4VRH2+g@mail.gmail.com>
References: <CALZVap=ybdWdK22LHsfSRu+TVCJnvL95KeChtCdX8DE-C=1gAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Javier Domingo <javierdo1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:56875 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758533Ab2J0UKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Oct 2012 16:10:47 -0400
Received: by mail-qa0-f53.google.com with SMTP id c1so856169qae.19
        for <netdev@vger.kernel.org>; Sat, 27 Oct 2012 13:10:46 -0700 (PDT)
In-Reply-To: <CALZVap=ybdWdK22LHsfSRu+TVCJnvL95KeChtCdX8DE-C=1gAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
You can find some info about net_device in this wiki page:
https://www.linuxfoundation.org/collaborate/workgroups/networking/networkoverview


A shameless plug - I wrote it.

Regards,
Rami Rosen

http://ramirose.wix.com/ramirosen



On Sat, Oct 27, 2012 at 6:18 PM, Javier Domingo <javierdo1@gmail.com> wrote:
> Hello,
>
> I am updating a kernel patch from 2.6.23-rc7 to v3.6, using git
> facilities, and I have found that there have been lots of changes in
> networking. Now the drivers are all by vendor, and more important,
> net_device is not used always, as napi_struct took its place.
>
> I have asked in #kernel but no one answered me, so I subscribed here.
> Is there any place I can read about how is it now designed the use of
> napi_struct and net_device? I have found a presentation[1] about how
> networking was changing etc, and I wondered if there is anything more
> precise about how it is actually implemented.
>
> I understand a little why napi_struct, but don't really know much
> about the change,
>
> Hope someone can help me,
>
> Javier Domingo
>
>
> [1]: http://vger.kernel.org/~davem/davem_nyc09.pdf
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
