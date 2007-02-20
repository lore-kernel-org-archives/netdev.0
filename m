From: "Dmitry Torokhov" <dmitry.torokhov@gmail.com>
Subject: Re: Network: convert network devices to use struct device instead of class_device
Date: Tue, 20 Feb 2007 10:15:26 -0500
Message-ID: <d120d5000702200715u130ee6b2i4a415aea24aa695d@mail.gmail.com>
References: <200702080400.l1840lFd002314@hera.kernel.org>
	 <45CB1AE6.9020707@garzik.org> <20070208074130.29df585f@oldman>
	 <d120d5000702080929r7016de12k292add26a0a72291@mail.gmail.com>
	 <20070209005601.GE30794@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	"Jeff Garzik" <jeff@garzik.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Kay Sievers" <kay.sievers@vrfy.org>
To: "Greg KH" <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:41615 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964976AbXBTPP3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 10:15:29 -0500
Received: by wr-out-0506.google.com with SMTP id i21so1900240wra
        for <netdev@vger.kernel.org>; Tue, 20 Feb 2007 07:15:28 -0800 (PST)
In-Reply-To: <20070209005601.GE30794@kroah.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/8/07, Greg KH <greg@kroah.com> wrote:
>
> And it should also alow for proper power management functionality, using
> the changes that Linus put into the driver core about 8 months ago.
>
> Don't worry, I have input patches queued up next for you Dmitry :)
>

Greg,

Could you please forward me these patches for input core - I am going
to rearrange some code and don't want too many clashes so I'd like to
apply yours to my private three and work from there...

Thanks!

-- 
Dmitry
