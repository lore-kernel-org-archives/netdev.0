From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fragmentation Attack
Date: Sat, 7 Feb 2004 09:45:24 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040207094524.495e883d.davem@redhat.com>
References: <BC4A7E2E.E256%gandalf@digital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Gandalf The White <gandalf@digital.net>
In-Reply-To: <BC4A7E2E.E256%gandalf@digital.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 07 Feb 2004 11:36:14 -0600
Gandalf The White <gandalf@digital.net> wrote:

> If you want step by step instructions I can provide them.

What makes your DoS interesting is whether the attacker needs
a lot of bandwidth or not.  Ie. if he has to be sitting on your
gigabit subnet then the attack isn't interesting.  Whereas if he
can eat all of the remote systems cpu cycles just being behind a
cable modem, that's interesting.

Which is it?

Also have you done your cpu utilization tests on something a little
less ancient than a 450mhz system?  How fast was the network?
