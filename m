From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Fri, 6 Jan 2012 17:34:39 -0800
Message-ID: <CA+55aFyk6QJib8UCtK_gWzidr8Ti1utJgHg359fkq=+GY8hbnw@mail.gmail.com>
References: <20120105.192833.760673635385506638.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120105.192833.760673635385506638.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 5, 2012 at 4:28 PM, David Miller <davem@davemloft.net> wrote:
>
> Netlink socket dumping is now supported for UDP and AF_UNIX sockets
> thanks to Pavel Emelyanov.

.. and this is such a magically important feature that it has to be
enabled by default?

It's something that has never been supported before, how did it
suddenly become 'default y' after twenty years of not even being an
issue?

It's a disease, I tell you, to think that new features are important.
Stop it. Tell people you take patches from to stop it. If we haven't
needed them before, they sure as hell aren't suddenly "Say Yes if you
don't know" material.

Please fix this, but more importantly, please try to fix *people*. So
I don't have to always react to the stupid new "default y" options.

                              Linus
