From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 timeouts with 2.6.17-rc6
Date: Fri, 16 Jun 2006 10:02:32 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC041BD16@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:53508 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751495AbWFPRCs convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 13:02:48 -0400
Content-class: urn:content-classes:message
To: "Juergen Kreileder" <jk@blackdown.de>, linux-kernel@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Juergen Kreileder

> I'm seeing frequent network timeouts on my PowerMac G5 Quad with
> 2.6.17-rc6.  The timeouts are easily reproducible with moderate
> network traffic, e.g. by using bittorrent.
> 

Did this use to work with an older kernel or older tg3 driver? If
yes, what version?

Please also provide the full tg3 probing output during modprobe and
ifconfig up. Thanks.

