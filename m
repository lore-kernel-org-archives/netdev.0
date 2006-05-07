From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2/2] netdev: create attribute_groups with
 class_device_add
Date: Sat, 06 May 2006 17:21:58 -0700 (PDT)
Message-ID: <20060506.172158.39305190.davem@davemloft.net>
References: <20060506040839.GA12636@kroah.com>
	<20060505.230050.56609951.davem@davemloft.net>
	<20060506225904.GA17704@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27853
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751146AbWEGAV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 20:21:56 -0400
To: greg@kroah.com
In-Reply-To: <20060506225904.GA17704@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <greg@kroah.com>
Date: Sat, 6 May 2006 15:59:04 -0700

> On Fri, May 05, 2006 at 11:00:50PM -0700, David S. Miller wrote:
> > The networking bit by Stephen is a bug fix.
> 
> Good point.  Ok, feel free to send both patches to Linus now if you
> want.  You can add my:
> 	Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> to the driver core change as I have no problems with it.
> Or I can send them on Monday if you wish.  Whatever is easier for you.

I'll take care of pushing the changes, thanks Greg.
