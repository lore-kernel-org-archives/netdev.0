From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] mark sk98lin driver for removal
Date: Sat, 22 Jul 2006 22:17:30 -0400
Message-ID: <20060723021730.GA5369@tuxdriver.com>
References: <20060722141150.5994fee1@localhost.localdomain> <20060722231703.GB8042@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:7690 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751066AbWGWCgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2006 22:36:31 -0400
To: Dave Jones <davej@redhat.com>
Content-Disposition: inline
In-Reply-To: <20060722231703.GB8042@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 22, 2006 at 07:17:03PM -0400, Dave Jones wrote:
> On Sat, Jul 22, 2006 at 02:11:50PM -0700, Stephen Hemminger wrote:
>  > The sk98lin driver is now superseded by the skge driver. I wanted to just
>  > let the old driver wither and die from old age, but there are still bugs
>  > that are too painful to fix.

>  > So rather than add more bondo to the old beater to cover the rusty bits,
>  > throw it in the dustbin.
>  > 
>  > Signed-off-by: Stephen Hemminger <shemminger@osdl.or
> 
> After a huge number of bug reports in Fedora 'went away' when we
> switched our users to using skge instead, I wholeheartedly endorse this.

> ACKed-by: Dave Jones <davej@redhat.com>

ACKed-by: John W. Linville <linville@tuxdriver.com>

-- 
John W. Linville
linville@tuxdriver.com
