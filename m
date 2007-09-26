From: "Karl Meyer" <adhocrocker@gmail.com>
Subject: Re: PROBLEM: 2.6.23-rc "NETDEV WATCHDOG: eth0: transmit timed out"
Date: Wed, 26 Sep 2007 11:07:52 +0200
Message-ID: <be1b757c0709260207ja3081f5ncdd3f340da9e8ca9@mail.gmail.com>
References: <be1b757c0708130435y689b9dd8raf9ac9f9c0fcc976@mail.gmail.com>
	 <be1b757c0708131027v5c57822as2d9bd3190fd19b71@mail.gmail.com>
	 <20070814070901.GA14693@electric-eye.fr.zoreil.com>
	 <be1b757c0708141425qd887581n3922702b84a21758@mail.gmail.com>
	 <20070814224629.GB3495@electric-eye.fr.zoreil.com>
	 <20070816141122.GA6625@electric-eye.fr.zoreil.com>
	 <be1b757c0709011224tafebaaby697d03ab5377e20f@mail.gmail.com>
	 <6bffcb0e0709021515v586f078cjce04f877e2f27aa2@mail.gmail.com>
	 <be1b757c0709021521q850f2bdq3f88c24c02c26b1b@mail.gmail.com>
	 <20070912205025.GA31709@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:61116 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754068AbXIZJHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 05:07:54 -0400
Received: by nf-out-0910.google.com with SMTP id g13so1900219nfb
        for <netdev@vger.kernel.org>; Wed, 26 Sep 2007 02:07:52 -0700 (PDT)
In-Reply-To: <20070912205025.GA31709@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Francois,

this is what I found and sent:

The error exists from patch 2 on. I did some network testing with
patch 1 and currently use it and have no errors so far.
>From my experiences up to now patch 1 should be error free.

Do you need additional info?

2007/9/12, Francois Romieu <romieu@fr.zoreil.com>:
> Karl Meyer <adhocrocker@gmail.com> :
> [...]
> > am am looking for this issue for some time now, but there where no
> > errors in 2.6.22-r2 (gentoo speak, I guess this is 2.6.22.2
> > officially), I also ran git-bisect (for more information see the older
> > messages in this thread).
>
> 2.6.22-r2 in gentoo is based on 2.6.22.1. It is way before
> 0e4851502f846b13b29b7f88f1250c980d57e944 that you reported to work.
> Thus it is not surprizing that it works.
>
> Any update regarding the patchkit that I sent on 2007/08/16 ?
>
> It would help to narrow the culprit.
>
> --
> Ueimor
>
