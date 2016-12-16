From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Fri, 16 Dec 2016 13:39:46 +0100
Message-ID: <CAHmME9pjoAsoct1sVDpFFuqaqutv9X7DGJ5OBQXRAS57KFimUA@mail.gmail.com>
References: <CAGiyFdfmiCMyHvAg=5sGh8KjBBrF0Wb4Qf=JLzJqUAx4yFSS3Q@mail.gmail.com>
 <20161216034618.28276.qmail@ns.sciencehorizons.net> <CAGiyFdd6_LVzUUfFcaqMyub1c2WPvWUzAQDCH+Aza-_t6mvmXg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: George Spelvin <linux@sciencehorizons.net>,
        Andi Kleen <ak@linux.intel.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        kernel-hardening@lists.openwall.com,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "Theodore Ts'o" <tytso@mit.edu>, vegard.nossum@gmail.com,
        "Daniel J . Bernstein" <djb@cr.yp.to>
To: Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:33266 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756867AbcLPMov (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Dec 2016 07:44:51 -0500
In-Reply-To: <CAGiyFdd6_LVzUUfFcaqMyub1c2WPvWUzAQDCH+Aza-_t6mvmXg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey JP,

On Fri, Dec 16, 2016 at 9:08 AM, Jean-Philippe Aumasson
<jeanphilippe.aumasson@gmail.com> wrote:
> Here's a tentative HalfSipHash:
> https://github.com/veorq/SipHash/blob/halfsiphash/halfsiphash.c
>
> Haven't computed the cycle count nor measured its speed.

This is incredible. Really. Wow!

I'll integrate this into my patchset and will write up some
documentation about when one should be used over the other.

Thanks again. Quite exciting.

Jason
