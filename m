From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Performance bottleneck with ndo_start_xmit
Date: Tue, 7 Jul 2015 11:10:31 -0700
Message-ID: <20150707111031.4ebabd36@urahara>
References: <CAHmME9rfOqA1mYmFDomcG+G55dV7it5406vL02ZRWcr0PmVbQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:32897 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932443AbbGGSKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 14:10:23 -0400
Received: by pacws9 with SMTP id ws9so118391264pac.0
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 11:10:22 -0700 (PDT)
In-Reply-To: <CAHmME9rfOqA1mYmFDomcG+G55dV7it5406vL02ZRWcr0PmVbQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 7 Jul 2015 18:32:22 +0200
"Jason A. Donenfeld" <Jason@zx2c4.com> wrote:

> I'm writing a kernel module that creates a virtual network device with
> rtnl_link_register.

Is it open source, is the source available to look at?
If not, please solve your own problems.
