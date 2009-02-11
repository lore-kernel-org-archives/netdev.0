From: Phillip Michael Jordan <phil@philjordan.eu>
Subject: Re: [PATCH] skge: Fix/workaround for DMA mask quirk on ASUS
	P5NSLI/Marvell Yukon-Lite
Date: Wed, 11 Feb 2009 01:19:13 +0100
Message-ID: <f1a0791a0902101619n201e8395pe39a6f7ecddaa786@mail.gmail.com>
References: <f1a0791a0902101056i6fd47886gc3cee4b5aff2a23e@mail.gmail.com>
	 <20090210111408.2225e90b@extreme>
	 <f1a0791a0902101415n47a825d9gf83d6908d6a8646a@mail.gmail.com>
	 <20090210144523.6f1e98e1@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:9454 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755740AbZBKATP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 19:19:15 -0500
Received: by fg-out-1718.google.com with SMTP id 16so70883fgg.17
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 16:19:13 -0800 (PST)
In-Reply-To: <20090210144523.6f1e98e1@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2009 at 11:45 PM, Stephen Hemminger
<shemminger@linux-foundation.org> wrote:
> I also want to know if it is a skge driver bug or Marvell only hardware
> problem.

Well, I'd definitely like to see this fixed properly if possible. If
you have any suggestions for how best to figure out what's going on,
that'd be great.

I could possibly arrange ssh&null-modem access to the system in
question in case that makes a difference. I'm pretty new to kernel
hacking as I'm sure you can tell, so there are probably (obvious?)
debugging options I haven't yet explored...

> Unfortunately, you are kind of far away for me to lend you hardware...

Do you know of any relatively inexpensive (or very common) hardware
that might help? I wasn't really planning to spend any money on this
fix, but if it's something I can put to good use (or maybe sell on
eBay) after testing then I'm not opposed to the idea.
