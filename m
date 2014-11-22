From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC] situation with csum_and_copy_... API
Date: Sat, 22 Nov 2014 09:48:46 -0800
Message-ID: <CA+55aFzFKhxs=oHHHs-Kr08qWNb4+q2NO1Vgrbp++-FWfJvuQg@mail.gmail.com>
References: <20141119.165340.2162829993279387495.davem@davemloft.net>
	<20141120214753.GR7996@ZenIV.linux.org.uk>
	<20141120.182339.972861702759954603.davem@davemloft.net>
	<20141121.122615.1091044030302005883.davem@davemloft.net>
	<20141122042856.GZ7996@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	target-devel <target-devel@vger.kernel.org>,
	"Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	Christoph Hellwig <hch@infradead.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141122042856.GZ7996@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 21, 2014 at 8:28 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>         OK, here's the next bunch.

Looks like good patches to me. Not that I actually _tested_ it, or
even have a good test-case (yeah, that "historical" ATM fix? I don't
think anybody cares ;), but it all seemed sane.

              Linus
