From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC] change netdevice to use struct device instead of struct
 class_device
Date: Mon, 03 Jul 2006 19:07:49 -0400
Message-ID: <44A9A345.8040706@garzik.org>
References: <20060703224719.GA14176@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58556 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750826AbWGCXHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 19:07:54 -0400
To: Greg KH <greg@kroah.com>
In-Reply-To: <20060703224719.GA14176@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH wrote:
> I have a patch here that converts the network device structure to use
> the struct device instead of struct class_device structure.  It's a bit
> too big to post here, so it's at:
> 	http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/network-class_device-to-device.patch

So....  this is a userspace ABI change, then?

	Jeff



