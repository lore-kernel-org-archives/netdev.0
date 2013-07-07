From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: Realtek driver issue in Ubuntu 12.01
Date: Sun, 7 Jul 2013 12:11:00 -0400
Message-ID: <20130707161100.GB7530@d2.synalogic.ca>
References: <51D98047.6010000@shaw.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, curtiswest@rogers.blackberry.net
To: Curtis West <curtiswest@shaw.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f51.google.com ([209.85.128.51]:61524 "EHLO
	mail-qe0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547Ab3GGQLF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jul 2013 12:11:05 -0400
Received: by mail-qe0-f51.google.com with SMTP id a11so1934539qen.10
        for <netdev@vger.kernel.org>; Sun, 07 Jul 2013 09:11:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <51D98047.6010000@shaw.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/07/07 10:50, Curtis West wrote:
> Hello:
> 
> I have come across your driver info and thought I would write you
> and see if you could help.
> 
> I recently purchased a Toshiba Satellite Pro C870 laptop and have
> successfully installed the latest version of Ubuntu 12.01.

Hello,

I would suggest following this guide from Ubuntu:
https://help.ubuntu.com/community/ReportingBugs

> 
> I then discovered that the wireless network  driver for my wifi was
> not working, and the  wired network was.
> 
> Not being very experienced writing command line Linux commands, I
> installed a graphical interface to identify which drivers that
> Ubuntu was using for my drivers.
> 
> This is where I found your email and information for the Realtek &
> the Linux r8169 crew.
> 
> So I am emailing you as you have experience writing drivers.

This is a mailing list, BTW.

> 
> So, if you are interested, I am hoping you may solve this problem,
> as I see many posts on the Ubuntu website trying to fix this
> problem.
> 
> I have the Realtek RTL8723AE wireless Lan 802.11(n) card according
> to the specs posted by Toshiba for this model.  The drivers that are
> installed according to the software I have used is the Realtek
> RTL-8169 Gigabit Ethernet Driver.

r8169 is likely the driver for your wired interface. rtl8723ae would be
the driver for your wifi card.

> 
> What do I need to do to get this wifi issue solved?
> 
> So, I hope this helps, if you are willing.
> 
> Any help is great.
> 
> Thanks,
> 
> Curtis West
> 403-852-8066
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
