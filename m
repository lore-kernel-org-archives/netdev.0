From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Mon, 21 Mar 2011 12:24:12 -0700
Message-ID: <AANLkTinN3qszBjbJdkXb2TPBkAW0mXGC=Ri1zKL9gdNg@mail.gmail.com>
References: <20110320.195156.226769634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110320.195156.226769634.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 20, 2011 at 7:51 PM, David Miller <davem@davemloft.net> wro=
te:
>
> 1) The R8169 PHY fix from Eric Dumazet, which I see you've added to
> =A0 your tree too. :-)

Yeah, since my machine didn't have networking without it, and I could
test it myself, I didn't wait to pull.

That said, I'm delaying this pull request due to the known issues with
it - let me know when you've updated it with the fix for the
use-after-free fixes and the slab corruptor (the latter of which I
haven't seen a patch for yet)

                         Linus
