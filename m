From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: netdev_ops retraction
Date: Wed, 30 Jul 2003 14:50:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030730185003.GA9253@gtf.org>
References: <20030730184416.GI22222@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matthew Wilcox <willy@debian.org>
Content-Disposition: inline
In-Reply-To: <20030730184416.GI22222@parcelfarce.linux.theplanet.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 30, 2003 at 07:44:16PM +0100, Matthew Wilcox wrote:
> Never mind the additional pointer dereference in the code, this is just
> a horribly large data structure.  Unless someone convinces me otherwise,
> I'm going to drop this idea and revert to doing ethtool_ops as a separate
> data structure.  I think there's still scope for a netdev_ops patch,
> but it's of dubious value and more of a 2.7 project.

Definitely OK with me.

And I think this is probably the best route for the moment, especially.

	Jeff
