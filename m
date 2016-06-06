From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Mon, 6 Jun 2016 10:38:58 -0700
Message-ID: <20160606173858.GA24836@kroah.com>
References: <1465222521-7217-1-git-send-email-mario_limonciello@dell.com>
 <1465222521-7217-2-git-send-email-mario_limonciello@dell.com>
 <20160606143947.GA4758@kroah.com>
 <e0b44bac635f41a9a3f47f909cf16f42@ausx13mpc124.AMER.DELL.COM>
 <20160606161222.GA12114@kroah.com>
 <e1fd0ce1589743acbd1342ec38ff8071@ausx13mpc124.AMER.DELL.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	pali.rohar@gmail.com, anthony.wong@canonical.com
To: Mario_Limonciello@Dell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <e1fd0ce1589743acbd1342ec38ff8071@ausx13mpc124.AMER.DELL.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2016 at 05:24:57PM +0000, Mario_Limonciello@Dell.com wrote:
> That said, I would be highly surprised if Realtek decided to implement
> with another OEM differently.  It would increase their code complexity
> on Windows as well since this is part of the generic driver.

Ah, it's refreshing to see people who haven't dealt with BIOS and system
vendors for very long, your good attitude is a wonderful sign :)

Seriously, if there is ANY chance that it could be broken or changed, it
will be.  I place the odds that your next hardware product will do just
this for no obvious reason at all and am willing to buy the beer if it
doesn't happen.

thanks,

greg k-h
