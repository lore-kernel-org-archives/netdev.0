From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: 3c59x
Date: Tue, 10 Jun 2003 15:20:52 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610192052.GA31962@gtf.org>
References: <20030610171617.GC1959@gtf.org> <20030610.101452.35033262.davem@redhat.com> <20030610172556.GD1959@gtf.org> <20030610.103030.15245573.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, bogdan.costescu@iwr.uni-heidelberg.de, hadi@shell.cyberus.ca,
   ralph+d@istop.com, xerox@foonet.net, sim@netnation.com, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030610.103030.15245573.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 10, 2003 at 10:30:30AM -0700, David S. Miller wrote:
> No end user will see the change then, no distribution vendor worth
> their salt will ship with MMIO enabled.
> 
> Right now we get only PIO and everybody suffers.  Runtime MMIO
> selection is a net win for everyone.

For 3c59x and select other drivers, I agree 100%

If we are making a general rule, I do not agree...

	Jeff
