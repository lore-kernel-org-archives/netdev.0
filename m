From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Is net-next open?
Date: Thu, 19 Jun 2014 07:03:37 -0700
Message-ID: <1403186617.1225.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1725EFC7@AcuExch.aculab.com>
	 <53A2A48D.5010805@redhat.com> <53A2EAC6.7010204@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Yi Li <lovelylich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:34833 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756700AbaFSODk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 10:03:40 -0400
Received: by mail-we0-f175.google.com with SMTP id k48so2376014wev.20
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2014 07:03:39 -0700 (PDT)
In-Reply-To: <53A2EAC6.7010204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-06-19 at 21:51 +0800, Yi Li wrote:
> 
> On 06/19/2014 04:51 PM, Daniel Borkmann wrote:
> > On 06/19/2014 10:46 AM, David Laight wrote:
> >> Has David M sent out the mail saying that net-next is open?
> >> I haven't seen it, but a few patches have been posted and he hasn't
> >> bounced them because it is closed.
> >
> > It's closed currently.
> Why is it closed currently?
> I have seen 3.16-rc1 have released, and from 
> https://www.kernel.org/doc/Documentation/networking/netdev-FAQ.txt, I 
> have got this message:
> "Shortly after the two weeks have passed (and vX.Y-rc1 is released), the
>     tree for net-next reopens to collect content for the next (vX.Y+1) 
> release."
>   Sorry, I am a newbie, but shouldn't net-next be open for now?

It is open when David decides so, and sends a mail stating it is open.

vX.Y-rc1 is released by Linus, and these guys have their own life.

David might enjoy some vacations for example.

Note that you can probably send a patch if you have one, but be prepared
for a delay if it is not a bug fix.
