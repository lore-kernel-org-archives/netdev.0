From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [AX25] kernel panic
Date: Sat, 29 Mar 2008 13:24:52 +0100
Message-ID: <20080329122452.GB3407@ami.dom.local>
References: <47E17E2E.9050105@free.fr> <20080320073021.GA4037@ff.dom.local> <47E2EC1B.9070405@free.fr> <20080322113620.GA3213@ami.dom.local> <47E68CA1.2040904@free.fr> <20080324205104.GA3721@ami.dom.local> <47E8FCE2.6000308@free.fr> <20080326183538.GA14266@ami.dom.local> <20080328120721.GA11060@ami.dom.local> <47EE3040.3050208@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Bernard Pidoux <bpidoux@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:51213 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbYC2MTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2008 08:19:17 -0400
Received: by nf-out-0910.google.com with SMTP id g13so311984nfb.21
        for <netdev@vger.kernel.org>; Sat, 29 Mar 2008 05:19:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47EE3040.3050208@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 29, 2008 at 01:04:16PM +0100, Bernard Pidoux wrote:
...
> Please find below an extract of /var/log/messages
> The time of interest is around 12:03
>
>
>  Mar 29 11:52:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f0a820
>  Mar 29 11:52:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0,  
> c0f0a820
>  Mar 29 11:52:53 f6bvp-9 kernel: AX25+ ax25_create, 866, c15602e0, c0f0a820
>  Mar 29 11:52:53 f6bvp-9 kernel: AX25- ax25_release, 959, c15602e0,  
> c0f0a820
>  Mar 29 11:52:59 f6bvp-9 kernel: AX25: ax25_frames_acked, 59, c6ae2bc8,  
> c0f0a040, 6b6b6b6b, 00000000, 00000000
...

Thanks Bernard! ...On the other hand, if you could hold these patches
a while yet and maybe find more of these "AX25:" it should be very
helpful (of course with other AX25* lines).

Regards,
Jarek P.
