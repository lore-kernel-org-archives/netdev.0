From: "David S. Miller" <davem@davemloft.net>
Subject: net-2.6.12 tree
Date: Wed, 26 Jan 2005 23:41:54 -0800
Message-ID: <20050126234154.4b0b17e7.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I didn't build it yet, sorry, will try again tomorrow.

Today's bug fix reviewing took all my time.  What's not
helping is that Linus is offline or concentrating on
something else, so he isn't sucking my net-2.6 tree in
at this time.

As mentioned I will push the non-bugfixers into there,
more specifically:

1) Thomas's EMATCH code
2) Arnaldo's sock allocation cleanups
3) Stephen's ipv6 TCP random port allocation patch

And I'll try to get to Einer's routing cache cleanups
which have been sitting in my backlog for far too long.
There's also the TCP md5 tree merge that never seems
to happen, fun fun fun. :-)
