From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [2.6 patch] net/bluetooth/: misc possible cleanups
Date: Sun, 26 Dec 2004 12:20:18 +0100
Message-ID: <1104060018.8758.51.camel@pegasus>
References: <20041214041352.GZ23151@stusta.de>
	 <1103009649.2143.65.camel@pegasus>  <20041219160758.GY21288@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Max Krasnyansky <maxk@qualcomm.com>, bluez-devel@lists.sourceforge.net,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Network Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041219160758.GY21288@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Adrian,

> > > Please comment on which of these changes are correct and which conflict 
> > > with pending patches.
> > 
> > Please send a separate patch for all the RFCOMM changes, because these
> > conflicts with some pending patches and then it will make it easier for
> > me to merge them.
> > 
> > The rest of the changes are fine with me, but I like to see also a
> > separate patch for the CMTP stuff and cmtp_send_capimsg() don't need a
> > forward declaration. Simply move the function to another place in the
> > source code.
> 
> splitted patches follow as reply to this email.

all of them are applied to my tree now. Thanks.

Regards

Marcel
