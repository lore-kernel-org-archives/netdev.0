From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [GIT] Networking
Date: Tue, 03 Nov 2015 11:56:16 +1100
Message-ID: <1446512176.17404.30.camel@kernel.crashing.org>
References: <20151027.233235.1641084823622810663.davem@davemloft.net>
	 <CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
	 <5637C8DF.800@kernel.org>
	 <CA+55aFwxDSYSB=bBfCxLadgCmFiOzAi0T0JHLFLK5nkR6cm8tg@mail.gmail.com>
	 <CA+55aFy6nC9tQFE_kRrF-YS9N7Jp18CnSxsLNcnAykNLyXQUtg@mail.gmail.com>
	 <CALCETrUxU_AVcQheeCXc0qTh=o2tmDbDct27QfTCb_+G6qc3gQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrUxU_AVcQheeCXc0qTh=o2tmDbDct27QfTCb_+G6qc3gQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-11-02 at 13:30 -0800, Andy Lutomirski wrote:
> 
> I'll stop making inane arguments if you stop bashing arguments I
> didn't make. :)  I said the helpers were useful for multiplication (by
> which I meant both signed and unsigned) and, to a lesser extent, for
> signed addition and subtraction.
> 
> I don't believe I even tried to justify usub_overflow as anything
> other than an extremely minor optimization that probably isn't
> worthwhile.

Also how much of the problem is simply that the function signature
(naming and choice of arguments) just plain sucks ?

Cheers,
Ben.
