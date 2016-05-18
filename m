From: Yuchung Cheng <ycheng@google.com>
Subject: Re: Make TCP work better with re-ordered frames?
Date: Wed, 18 May 2016 11:17:14 -0700
Message-ID: <CAK6E8=fTB+AAL+pAonTY57f9VSfgVbijVdc0QT=+R_X3e_-Hzg@mail.gmail.com>
References: <573C758E.9050008@candelatech.com> <1463581760.18194.114.camel@edumazet-glaptop3.roam.corp.google.com>
 <573C8547.3020709@candelatech.com> <1463585133.18194.119.camel@edumazet-glaptop3.roam.corp.google.com>
 <573C8E42.8090102@candelatech.com> <1463587366.18194.130.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Greear <greearb@candelatech.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:35014 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751736AbcERSRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 14:17:55 -0400
Received: by mail-wm0-f48.google.com with SMTP id r12so47135439wme.0
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 11:17:55 -0700 (PDT)
In-Reply-To: <1463587366.18194.130.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2016 at 9:02 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> On Wed, 2016-05-18 at 08:46 -0700, Ben Greear wrote:
>
> > I will work on captures...do you care if it is from transmitter or receiver's perspective?
>
> Receiver would probably be more useful.
Can I get sender side traces too? I am working on improving TCP
reordering at the sender side. Thanks.
>
>
