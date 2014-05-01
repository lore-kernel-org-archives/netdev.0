From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: HHF support in iproute2?
Date: Thu, 1 May 2014 09:42:39 -0700
Message-ID: <20140501094239.683e627d@nehalam.linuxnetplumber.net>
References: <4420ec641916f42ac8bb9becc634a8cf@visp.net.lb>
	<5362670F.2080400@gmail.com>
	<CAOaVG153tfEqZvr3EC9Z1-Tc1ZWaQ6tVvswarYxtPzVRuQ88HA@mail.gmail.com>
	<53627483.2050507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>,
	netdev <netdev@vger.kernel.org>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:52566 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751237AbaEAQmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 12:42:49 -0400
Received: by mail-pd0-f171.google.com with SMTP id r10so3433833pdi.2
        for <netdev@vger.kernel.org>; Thu, 01 May 2014 09:42:49 -0700 (PDT)
In-Reply-To: <53627483.2050507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 01 May 2014 09:21:23 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> On 05/01/2014 08:41 AM, Stephen Hemminger wrote:
> > I find/pick up patches from patchwork.
> > If it wasn't there then it didn't get picked up
> >
> 
> Its in patchwork I just don't see it in the package I pulled from
> git.kernel.org. I looked in the master and net-next-for-3.13 branches.
> 
> The patchwork patch is,
> 
> http://patchwork.ozlabs.org/patch/308514/
> 
> >
> > On Thu, May 1, 2014 at 8:23 AM, John Fastabend <john.fastabend@gmail.com
> > <mailto:john.fastabend@gmail.com>> wrote:
> >
> >     On 04/11/2014 09:11 PM, Denys Fedoryshchenko wrote:
> >
> >         Hi
> >
> >         I just tried recently last iproute2 (git and release) and noticed in
> >         iproute-3.14.0 it is still missing HHF support, while i see it is
> >         accepted in git
> >         (http://marc.info/?l=linux-__netdev&m=138933793006411&w=2
> >         <http://marc.info/?l=linux-netdev&m=138933793006411&w=2>)
> >         Is there any problem with this scheduling discipline?
> >
> >         Thanks!
> >
> >
> >     Hi Stephen,
> >
> >     I can't seem to find this patch either. I checked the repository
> >     at git.kernel.org <http://git.kernel.org> and it looks like q_hhf.c
> >     is missing.
> >
> >     Was this intentional? Or am I just missing something. I have the
> >     patch applied locally and it seems to work OK.
> >
> >     Thanks,
> >     John
> >
> >     --
> >     John Fastabend         Intel Corporation
> >
> >
> 
> 
> 

Let me investigate net-next-3.13 was merged.
