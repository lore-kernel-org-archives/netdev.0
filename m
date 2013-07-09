From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 9 Jul 2013 10:32:56 -0700
Message-ID: <CA+55aFxbipsZFC2iQsVchstOP_7mR48sUbo96LEJ4kxtZWQDKQ@mail.gmail.com>
References: <20130707.132133.1335860703202153192.davem@davemloft.net>
	<CA+55aFzgBXwye=ebPmEDN_6yqdKA6ZaD9hSUzbFjSacC_v3y5g@mail.gmail.com>
	<1373336940.27613.24@driftwood>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Rob Landley <rob@landley.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373336940.27613.24@driftwood>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 8, 2013 at 7:29 PM, Rob Landley <rob@landley.net> wrote:
>
> Um, does that mean I should have cc'd you on the initmpfs patch series
> back before the merge window opened?

So I personally don't tend to care about that kind of patch-series -
it doesn't really add new features to basic code unlike the polling
changes. But I suspect for something like that series, the people to
cc are Al Viro and Hugh Dickins because they maintain vfs adn tmpfs
respectively.. That said, I think neither really cares.deeply, and
this looks like a "Andrew" patch-series if only because it's so random
;)

           Linus
