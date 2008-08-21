From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: __netif_schedule on e1000e and 2.6.26-rc4
Date: Thu, 21 Aug 2008 12:04:24 -0400
Message-ID: <9e4733910808210904q3cbe5400m90b086c864dd2811@mail.gmail.com>
References: <9e4733910808210836v6ec098daode36859ae52685ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f16.google.com ([209.85.217.16]:64093 "EHLO
	mail-gx0-f16.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215AbYHUQE1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 12:04:27 -0400
Received: by gxk9 with SMTP id 9so238379gxk.13
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 09:04:25 -0700 (PDT)
In-Reply-To: <9e4733910808210836v6ec098daode36859ae52685ed@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/21/08, Jon Smirl <jonsmirl@gmail.com> wrote:
> I'm hitting the __netif_schedule warning on 82566DC/e1000e with rc4.
>
>  This link hasn't gone up/down before in the past. It is a 24in cable
>  to the switch.

I need to check on this more, I had a build failure and the machine
wasn't really updated.

-- 
Jon Smirl
jonsmirl@gmail.com
