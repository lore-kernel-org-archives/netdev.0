From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v5 1/4] siphash: add cryptographically secure PRF
Date: Fri, 16 Dec 2016 21:43:40 +0100
Message-ID: <CAHmME9rr7A-ffz81N5jUzjg2k1UdM=-QLfcSDH_aOwrC-OFDpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>, Andi Kleen <ak@linux.intel.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@aculab.com>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Eric Biggers <ebiggers3@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        kernel-hardening@lists.openwall.com,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Netdev <netdev@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Vegard Nossum <vegard.nossum@gmail.com>
To: George Spelvin <linux@sciencehorizons.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 16, 2016 at 9:41 PM, George Spelvin
<linux@sciencehorizons.net> wrote:
> What are you testing on?  And what input size?  And does "33% improvement"
> mean 4/3 the rate and 3/4 the time?  Or 2/3 the time and 3/2 the rate?

How that I've published my hsiphash implementation to my tree, it
should be possible to conduct the tests back to back with nearly
identical implementation strategies, to remove a potential source of
error.
