From: Dan Williams <dcbw@redhat.com>
Subject: Re: [GIT] Networking
Date: Thu, 02 May 2013 14:17:34 -0500
Message-ID: <1367522254.7757.23.camel@dcbw.foobar.com>
References: <20130501.164755.1859264969403837546.davem@davemloft.net>
	 <CA+55aFzsvyQLLKbuETBqfhpgkSaXH9cvT0O-cQ-mTTXXxcMqwg@mail.gmail.com>
	 <1367512467.4000.7.camel@dcbw.foobar.com>
	 <1367519066.7757.19.camel@dcbw.foobar.com>
	 <CA+55aFy04mY5g-Aics9dcGpv6zgn2bu4iQ-_ifE5hun_t4E54Q@mail.gmail.com>
	 <CA+55aFy1P6TKZjWSvrJN6o=gAr7OTYQsoZORXGF6g8OnonBT=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	hayeswang <hayeswang@realtek.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFy1P6TKZjWSvrJN6o=gAr7OTYQsoZORXGF6g8OnonBT=Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-05-02 at 11:53 -0700, Linus Torvalds wrote:
> On Thu, May 2, 2013 at 11:52 AM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > but for some reason in the bad case NM just doesn't react past the
> > "carrier now ON" part.
> 
> Grr. That was much more readable while editing, then gmail ended up
> doing its "smart line wrap" thing and my nice long lines became a
> mess. I think you can still figure it out,

Yeah, the dump is good, and it seems to point to a problem in NM for
now.  I'm investigating.

Dan
