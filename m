From: "M. Istehbab" <hariskhan@gmail.com>
Subject: Re: TCP connection failure in kernel 2.6.25
Date: Fri, 9 May 2008 00:32:26 +0500
Message-ID: <c1410bfe0805081232k3be4ddcew2647207fee057e8c@mail.gmail.com>
References: <c1410bfe0804260217t33139fd2v324af1a149843989@mail.gmail.com>
	 <1209205136.2929.6.camel@localhost.localdomain>
	 <c1410bfe0804260516k1149fadaoc06f02b94dcd12e9@mail.gmail.com>
	 <1209241624.2929.17.camel@localhost.localdomain>
	 <c1410bfe0804262302p3f283f9k97a04ff11dd2779e@mail.gmail.com>
	 <1209315362.2934.55.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "H. Willstrand" <h.willstrand@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:38011 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756090AbYEHTc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 15:32:27 -0400
Received: by wf-out-1314.google.com with SMTP id 27so836061wfd.4
        for <netdev@vger.kernel.org>; Thu, 08 May 2008 12:32:26 -0700 (PDT)
In-Reply-To: <1209315362.2934.55.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/27/08, H. Willstrand <h.willstrand@gmail.com> wrote:
>
> So, you have the same issue with all tested kernels
> RHEL 3 works, Debian fails
>
> This smells configuration failure, you better compare your working
> configuration with the others.
>
> // H.Willstrand
>

When I was using RHEL WS3, which comes with kernel 2.4.21-27.EL
(sorry, the 2.6.9 comes with rhel 4), it worked ok. I haven't tried
new kernels on rhel ws3 though.

I tried all the mentioned kernel versions on debian. All show the same problem.

Note sure if its config or what, but this problem exists.

M. Istehbab
