From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCHES] iov_iter.c rewrite
Date: Mon, 8 Dec 2014 11:01:41 -0800
Message-ID: <CA+55aFwow9hVqNVGp7gjnnu4=A+J8vw1i22W4e7+1r1-215cHg@mail.gmail.com>
References: <20141204202011.GO29748@ZenIV.linux.org.uk>
	<20141208164650.GB29028@node.dhcp.inet.fi>
	<20141208175805.GB22149@ZenIV.linux.org.uk>
	<20141208185635.GA25867@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141208185635.GA25867@node.dhcp.inet.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 8, 2014 at 10:56 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
> trinity triggers it for me in few minutes. I will try find out more once
> get some time.

You run trinity as *root*?

You're a brave man. Stupid, but brave ;)

I guess you're running it in a VM, but still.. Doing random system
calls as root sounds like a bad bad idea.

                      Linus
