From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH / RFC 0/2] spinlocks fixup in fec / m68knommu driver
Date: Wed, 02 Apr 2008 22:50:03 +1000
Message-ID: <47F380FB.4040904@snapgear.com>
References: <20080327140041.072611004@linutronix.de> <47EC9577.2090402@snapgear.com> <47F36DD5.20902@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: uclinux-dev@uclinux.org, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
To: Sebastian Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosted02.westnet.com.au ([203.10.1.213]:53321 "EHLO
	hosted02.westnet.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527AbYDBMuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 08:50:22 -0400
In-Reply-To: <47F36DD5.20902@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sebastian Siewior wrote:
> Greg Ungerer wrote:
>> Hi Sebastion,
> s/o/a :)

Sorry :-)

>> No, it looks broken :-(
> I'm going to post a cleanup patch and a locking fixup patch. The missing 
> lock is more serious than I though in first place.

Be aware there are other known problems with this driver "as is".
Search for the recent discussion on uclinux-dev mailing list
about it.

Regards
Greg


------------------------------------------------------------------------
Greg Ungerer  --  Chief Software Dude       EMAIL:     gerg@snapgear.com
SnapGear -- a Secure Computing Company      PHONE:       +61 7 3435 2888
825 Stanley St,                             FAX:         +61 7 3891 3630
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.com
