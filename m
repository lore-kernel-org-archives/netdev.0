From: Dave Jones <davej@redhat.com>
Subject: Re: PATCH: kmalloc packet slab
Date: Tue, 28 Dec 2004 01:01:48 -0500
Message-ID: <20041228060148.GB5481@redhat.com>
References: <1104156983.20944.25.camel@localhost.localdomain> <41D043AC.2070203@trash.net> <20041227142350.1cf444fe.davem@davemloft.net> <1104195085.20898.62.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>,
        torvalds@osdl.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Content-Disposition: inline
In-Reply-To: <1104195085.20898.62.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Dec 28, 2004 at 12:51:28AM +0000, Alan Cox wrote:
 > On Llu, 2004-12-27 at 22:23, David S. Miller wrote:
 > > If we are really going to do something like this, it should
 > > be calculated properly and be determined per-interface
 > > type as netdevs are registered.
 > 
 > Fine by me, I'm just going through plausible looking changes in the Red
 > Hat tree. You might want to slightly injure someone internally until
 > they drop that too 8)

Internal injuries unnecessary. Regardless of outcome of this patch,
Fedora will pick up whatever happens upstream instead of carrying
this any longer. This and a few other patches have been stagnating
in our tree for far longer than they should have been.

		Dave
