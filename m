From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v7 1/6] siphash: add cryptographically secure PRF
Date: Thu, 22 Dec 2016 02:42:39 +0100
Message-ID: <CAHmME9pq+no-crKEo77kLGW5FzLzpHhQm1=4-tWiSDhGdVdo+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        David Laight <David.Laight@aculab.com>,
        Ted Tso <tytso@mit.edu>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <edumazet@google.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Andi Kleen <ak@linux.intel.com>,
        David Miller <davem@davemloft.net>,
        Andy Lutomirski <luto@amacapital.net>,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 22, 2016 at 2:40 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> The networking tree (net-next) which is where you are submitting to is technically
> closed right now.

That's okay. At some point in the future it will be open. By then v83
of this patch set will be shiny and done, just waiting for the merge
window to open. There's a lot to discuss with this, so getting the
feedback early is beneficial.

Jason
