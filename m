From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: netdev_ops?
Date: Wed, 23 Jul 2003 12:59:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030723165914.GA29249@gtf.org>
References: <3F1E17BC.30100@candelatech.com> <20030722220745.379a73c6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030722220745.379a73c6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jul 22, 2003 at 10:07:45PM -0700, David S. Miller wrote:
> On Tue, 22 Jul 2003 22:06:04 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> > Any progress towards getting the netdev_ops into 2.4?
> > 
> > I have several patches that would benefit (in that no new ioctls
> > would be needed) if this goes in.
> 
> If anything, it's going to go into 2.6.x first, and then backported
> to 2.4.x after it's had a few months of testing and tweaking.

Agreed.

FWIW Matthew and I (and several others) are at OLS and basically out of
commission for a week, so pretty-please don't make any major decisions
this week ;-)

	Jeff
