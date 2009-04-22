From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [patch 0/8] iucv / af_iucv patches for net-next-2.6.30-rc1
Date: Wed, 22 Apr 2009 13:39:16 +0200
Message-ID: <1240400356.13951.11.camel@braunu-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	ursula.braun@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:42708 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339AbZDVLjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 07:39:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>Do I need to pull net-2.6 into net-next-2.6 for this stuff
>to apply properly?
>
>Just checking.

Dave,

the af_iucv-patches sent today apply to net-next-2.6 without pulling
yesterday's patches for net-2.6.

If you prefer to pull net-2.6 first (in order to avoid potential future
merge conflicts), I can rebuild and resend today's net-next-2.6 patches
based on yesterday's af_iucv patches for net-2.6.

Regards, Ursula Braun

