From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [Fwd: pcmcia ether drivers can't be unloaded]
Date: Mon, 2 Aug 2004 20:02:10 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040802200210.A9498@flint.arm.linux.org.uk>
References: <41068BEF.7010200@pobox.com> <20040727233614.B30782@flint.arm.linux.org.uk> <20040727171929.17858c7b.davem@redhat.com> <20040728165024.A8475@flint.arm.linux.org.uk> <20040728085419.773c4d94.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, shemminger@osdl.org, netdev@oss.sgi.com, greg@kroah.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040728085419.773c4d94.davem@redhat.com>; from davem@redhat.com on Wed, Jul 28, 2004 at 08:54:19AM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 28, 2004 at 08:54:19AM -0700, David S. Miller wrote:
> On Wed, 28 Jul 2004 16:50:24 +0100
> Russell King <rmk@arm.linux.org.uk> wrote:
> 
> > On Tue, Jul 27, 2004 at 05:19:29PM -0700, David S. Miller wrote:
> > > I totally disagree.  This is a bogus argument for two reasons:
> > 
> > You may disagree, that is your option.  However, facts are facts -
> > this is how the PCMCIA layer currently works, and short of rewriting
> > the whole damned thing it isn't going to change.  Sorry.
> 
> Stephen offered a solution, moving this stray refcount into a toplevel
> pcmcia bus type object.  We are not constrained by how the PCMCIA layer
> currently works, just as we were not constrained a year ago by how the
> generic network device handling worked when it was totally broken in
> this area.  We just fixed it instead of whining.

Sorry, I'm not the one whining here.  I just have _ZERO_ time at the moment
because I'm still in Canada and only have sporadic access to stuff.

Sorry if this doesn't meet your requirements, but this is the best I can
offer you at the moment.

In short, my best and only answer is "tough, live with it until I can
investigate."

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 PCMCIA      - http://pcmcia.arm.linux.org.uk/
                 2.6 Serial core
