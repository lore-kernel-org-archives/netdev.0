From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [RFC PATCH v1 0/3] usbnet: runtime suspend when link becomes down
Date: Tue, 18 Sep 2012 22:36:26 +0800
Message-ID: <CACVXFVM5U8O0QbdmaxCAfgoiZhyeo99dOQXGsEh-JT5kaf+3rA@mail.gmail.com>
References: <1347978201-6219-1-git-send-email-ming.lei@canonical.com>
	<29958246.BU7m2dD7VT@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Fink Dmitry <finik@ti.com>, Rafael Wysocki <rjw@sisk.pl>,
	Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Oliver Neukum <oneukum@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:37857 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933176Ab2IROg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 10:36:28 -0400
In-Reply-To: <29958246.BU7m2dD7VT@linux-lqwf.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 18, 2012 at 10:28 PM, Oliver Neukum <oneukum@suse.de> wrote:
> On Tuesday 18 September 2012 22:23:18 Ming Lei wrote:
>> Hi,
>>
>> Currently only very few usbnet devices support the traffic based
>> runtime PM, eg. wake up devices if there are packets to be transmitted.
>
> Hi,
>
> independent of the rest it seems to me that the first two patches in your
> series are a useful cleanup by themselves. Could you submit them separately?

IMO, if the first two are OK now, David may commit the first two only.

Thanks,
--
Ming Lei
