From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 iproute2] ip: Add color output option
Date: Mon, 27 Apr 2015 16:37:04 -0700
Message-ID: <20150427163704.65d53140@urahara>
References: <20150424113451.GA8133@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aleksi.aalto@iki.fi
To: Mathias Nyman <m.nyman@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35400 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753167AbbD0XhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 19:37:01 -0400
Received: by pabtp1 with SMTP id tp1so145072918pab.2
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2015 16:37:00 -0700 (PDT)
In-Reply-To: <20150424113451.GA8133@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch does not apply cleanly to current version in git.
All patches should be based off of 

  http://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git

I suspect your mailer is corrupting whitespace.
Maybe easier to send patch as an attachment.

$ patch -p1 < ~/Downloads/v3-iproute2-ip-Add-color-output-option.patch 
patching file include/color.h
patching file ip/ip.c
Hunk #1 FAILED at 23.
Hunk #2 FAILED at 56.
Hunk #3 FAILED at 257.
3 out of 3 hunks FAILED -- saving rejects to file ip/ip.c.rej
patching file ip/ipaddress.c
Hunk #1 FAILED at 34.
Hunk #2 FAILED at 136.
Hunk #3 FAILED at 606.
Hunk #4 FAILED at 666.
Hunk #5 FAILED at 849.
5 out of 5 hunks FAILED -- saving rejects to file ip/ipaddress.c.rej
patching file lib/Makefile
Hunk #1 FAILED at 7.
1 out of 1 hunk FAILED -- saving rejects to file lib/Makefile.rej
patching file lib/color.c
patching file man/man8/ip.8
Hunk #1 FAILED at 33.
Hunk #2 FAILED at 165.
2 out of 2 hunks FAILED -- saving rejects to file man/man8/ip.8.rej
