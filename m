From: Daniele Venzano <webvenza@libero.it>
Subject: Re: [PATCH 1/5] sis900 debugging and revision code
Date: Fri, 7 Jan 2005 12:58:32 +0100
Message-ID: <20050107115832.GB14223@picchio.gall.it>
References: <20041212121852.GA16325@gateway.milesteg.arr> <20041212123031.GB16325@gateway.milesteg.arr> <41DDCB54.2080101@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41DDCB54.2080101@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 06, 2005 at 06:35:48PM -0500, Jeff Garzik wrote:
> Patches 1, 2, and 5 are OK.
> 
> For the other two patches, I don't want to deviate from the style that 
> has been standard for years:  dev->name prefix, followed by message.
> 
> It may make greps easier for you, but it becomes a non-standard style 
> and may make existing sysadmin scripts out in the field.
> 
> Please resend series without the PFX-where-devname-is-known changes.

Ok, I just don't have time to do it right now, but I'll rediff ASAP.
However a message reformat patch will be needed because there are some
messages that don't conform to either (mine or established) standard.

Also I think I'll add at the end of the patchset a new patch that was
sent recently on linux-kernel that adds support for netconsole.


Bye.

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org
