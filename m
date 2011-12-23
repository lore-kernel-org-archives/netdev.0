From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [net-next 8/9] ixgbe: add interface to export thermal data
Date: Fri, 23 Dec 2011 18:58:48 +0100
Message-ID: <CAHXqBFL_44T5nQVA=n03aT9Q1QpsLCY2dn9o6GE-9Rm66DSt-A@mail.gmail.com>
References: <1324631357-31789-1-git-send-email-jeffrey.t.kirsher@intel.com> <1324631357-31789-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Don Skidmore <donald.c.skidmore@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:50161 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285Ab1LWR7J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 12:59:09 -0500
Received: by iaeh11 with SMTP id h11so15410135iae.19
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 09:59:09 -0800 (PST)
In-Reply-To: <1324631357-31789-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/12/23 Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
> From: Don Skidmore <donald.c.skidmore@intel.com>
>
> Some of our adapters have thermal data available, this patch exports =
this
> data via a read-only sysfs interface.

Just curious: can't this use the hwmon subsystem to be consistent with
other system monitoring devices?

Best Regards,
Micha=B3 Miros=B3aw
