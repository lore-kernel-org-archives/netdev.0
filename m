From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH V3] Export SMBIOS provided firmware instance and label
	to sysfs
Date: Fri, 23 Jul 2010 06:55:57 -0700
Message-ID: <20100723135557.GA3624@kroah.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE612C40@blrx3m08.blr.amer.dell.com> <20100723133456.GA9378@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-pci@vger.kernel.org, matt_domsch@dell.com,
	charles_rose@dell.com, jordan_hargrave@dell.com,
	vijay_nijhawan@dell.com
To: Narendra K <Narendra_K@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100723133456.GA9378@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 23, 2010 at 08:34:56AM -0500, Narendra K wrote:
> --- a/Documentation/ABI/testing/sysfs-bus-pci
> +++ b/Documentation/ABI/testing/sysfs-bus-pci
> @@ -179,3 +179,30 @@ Contact:	linux-pci@vger.kernel.org
>  Description:
>  		This symbolic link points to the PCI hotplug controller driver
>  		module that manages the hotplug slot.
> +
> +What:		/sys/bus/pci/devices/.../label
> +Date:		July 2010
> +Contact:	linux-bugs@dell.com

that's not your email address.  Please don't hide behind some random
address, Linux is about contacting developers directly were ever
possible.

thanks,

greg k-h
