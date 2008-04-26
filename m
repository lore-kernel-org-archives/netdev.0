From: "H. Willstrand" <h.willstrand@gmail.com>
Subject: Re: TCP connection failure in kernel 2.6.25
Date: Sat, 26 Apr 2008 22:27:04 +0200
Message-ID: <1209241624.2929.17.camel@localhost.localdomain>
References: <c1410bfe0804260217t33139fd2v324af1a149843989@mail.gmail.com>
	 <1209205136.2929.6.camel@localhost.localdomain>
	 <c1410bfe0804260516k1149fadaoc06f02b94dcd12e9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "M. Istehbab" <hariskhan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:43691 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757810AbYDZUcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 16:32:10 -0400
Received: by nf-out-0910.google.com with SMTP id g13so1650039nfb.21
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2008 13:32:09 -0700 (PDT)
In-Reply-To: <c1410bfe0804260516k1149fadaoc06f02b94dcd12e9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-04-26 at 17:16 +0500, M. Istehbab wrote:
> Yes, after a while (it can be a few seconds, minutes, or 1+ hour) the
> proxy server starts accepting connections again. I don't need to
> reboot the box when this happens.
> 
> This happens randomely to anyone behind it. Then, after a while, it
> starts working again by itself.
> 
Well, there are too many possibilities for failures... the Linux
distribution (RHEL 3 workstation) was built for 2.4.21 (around year
2003) and you try 2.6.x

Maybe you should stick to one of the later 2.4.x kernels or even better
upgrade the Linux distribution.

Cheers,
H. Willstrand
  
> M. Istehbab
> 
> On 4/26/08, H. Willstrand <h.willstrand@gmail.com> wrote:
> >
> > >
> >
> > Is the proxy server accepting connections after the issue has occurred?
> > Or do you need to re-boot? Or do you have to wait for a number of
> > seconds or what?
> >
> > Cheers,
> > H. Willstrand
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

