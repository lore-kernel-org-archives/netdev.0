From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] 2.4.22-pre9-bk : bonding bug fixes
Date: Wed, 30 Jul 2003 16:49:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030730164907.43b2d343.davem@redhat.com>
References: <20030730140658.GA14437@alpha.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Willy Tarreau <willy@w.ods.org>
In-Reply-To: <20030730140658.GA14437@alpha.home.local>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 30 Jul 2003 16:06:58 +0200
Willy Tarreau <willy@w.ods.org> wrote:

> there are still a few bugs in the current bonding driver. I've reported them
> several times now, but perhaps not at the right places...

So now we have these few bug fixes, and the backport of the
2.6.x version of the bonding code, both submitted on the same
day in fact :-)

Jeff I'd recommend we put Willy's fixes in if you think they're
OK, then we can think about the 2.6.x backport work for 2.4.23-preX
