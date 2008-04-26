From: "M. Istehbab" <hariskhan@gmail.com>
Subject: Re: TCP connection failure in kernel 2.6.25
Date: Sat, 26 Apr 2008 17:16:38 +0500
Message-ID: <c1410bfe0804260516k1149fadaoc06f02b94dcd12e9@mail.gmail.com>
References: <c1410bfe0804260217t33139fd2v324af1a149843989@mail.gmail.com>
	 <1209205136.2929.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:31382 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbYDZMQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 08:16:39 -0400
Received: by wf-out-1314.google.com with SMTP id 28so3262551wff.4
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2008 05:16:38 -0700 (PDT)
In-Reply-To: <1209205136.2929.6.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes, after a while (it can be a few seconds, minutes, or 1+ hour) the
proxy server starts accepting connections again. I don't need to
reboot the box when this happens.

This happens randomely to anyone behind it. Then, after a while, it
starts working again by itself.

M. Istehbab

On 4/26/08, H. Willstrand <h.willstrand@gmail.com> wrote:
>
> >
>
> Is the proxy server accepting connections after the issue has occurred?
> Or do you need to re-boot? Or do you have to wait for a number of
> seconds or what?
>
> Cheers,
> H. Willstrand
>
