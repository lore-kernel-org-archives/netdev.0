From: Greg KH <gregkh@suse.de>
Subject: Re: ?^?H?G Re: [linux-usb-devel] Please pull 'ssb-drivers' branch
	of wireless-2.6  -- aln.
Date: Fri, 21 Sep 2007 15:19:35 -0700
Message-ID: <20070921221935.GA8191@suse.de>
References: <OF5E769610.A64618C1-ON4825735D.000F9F12@sdc.sercomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	David Brownell <david-b@pacbell.net>,
	linux-usb-devel@lists.sourceforge.net, jeff@garzik.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-usb-users@lists.sourceforge.net, mb@bu3sch.de,
	zambrano@broadcom.com, davem@davemloft.net
To: Alninuo_Li@sdc.sercomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:56634 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752933AbXIUWVV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 18:21:21 -0400
Content-Disposition: inline
In-Reply-To: <OF5E769610.A64618C1-ON4825735D.000F9F12@sdc.sercomm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 21, 2007 at 10:58:37AM +0800, Alninuo_Li@sdc.sercomm.com wrote:
> 
> Hi Greh,

hm, I don't know of anyone by that name :)

You might not want to take over a totally different thread for your
question, it doesn't make much sense that way...

>       I donot know how to ask question to u, so use this reply.
>       We are focusing on 2.4.20 to make use of usbserial driver work for
> Notevel U740, but it would crash after long run, seem the Interrupt
> stopped, and can't send down, stoped at generic_write func call alwways
> return with busy.
>       And could you tell us some idea or how to debug the code, when we
> open the usb debug, it would crash quickly, since the printk have huge
> messages,  is there good idea to debug or how to go?

No one supports 2.4.20 anymore, sorry.  I suggest you move to the 2.6
kernel tree instead.

good luck,

greg k-h
