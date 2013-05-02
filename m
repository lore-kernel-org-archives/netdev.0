From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v2 net-next] net/usb: new driver for RTL8152
Date: Thu, 2 May 2013 07:12:39 -0700
Message-ID: <20130502141239.GC24348@kroah.com>
References: <1366965948-1805-1-git-send-email-hayeswang@realtek.com>
 <1367524087-29512-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oliver@neukum.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1367524087-29512-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 03, 2013 at 03:48:07AM +0800, Hayes Wang wrote:
> +#define PATENTS		"This product is covered by one or more of the " \
> +			"following patents:\n" \
> +			"\t\tUS6,570,884, US6,115,776, and US6,327,625.\n"

Interesting, you are aware of the issues involved with patents and GPLv2
code, right?  Do you have a pointer to the GPLv2 patent release that is
now required, or does your company now release all of the needed rights
for these patents to be able to be used by everyone?

thanks,

greg k-h
