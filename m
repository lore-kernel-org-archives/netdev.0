From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] X86: Removing inline decl on arch/x86/include/asm/desc.h.
Date: Wed, 16 Nov 2016 12:15:08 -0800
Message-ID: <1479327308.8455.215.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1479239164-7721-1-git-send-email-asd@marian1000.go.ro>
         <alpine.DEB.2.20.1611162005320.3697@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ingo Molnar <mingo@redhat.com>,
        "H. Peter Anvin" <hpa@zytor.com>,
        Realtek linux nic maintainers <nic_swsd@realtek.com>,
        x86@kernel.org, linux-kernel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35696 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752546AbcKPUPL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 15:15:11 -0500
In-Reply-To: <alpine.DEB.2.20.1611162005320.3697@nanos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-16 at 20:16 +0100, Thomas Gleixner wrote:
> On Tue, 15 Nov 2016, Corcodel Marian wrote:
> >  Inline declarations suppress warning message from compiler but
> >  most of these functions was declared static and is not used local on file.
> 
> Huch? This is a header file and the functions are marked inline on purpose.
> 
> Can you please explain what you are trying to achieve and why you think
> that this is a good idea?

Corcodel Marian is a bot.
Do not bother Thomas. 
Total Waste of time.

https://www.spinics.net/lists/netdev/msg370788.html

https://www.mail-archive.com/netdev@vger.kernel.org/msg103775.html
