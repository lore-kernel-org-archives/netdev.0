From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/2] OpenCores 10/100 MAC fixes for gigabit
 environment
Date: Tue, 04 Feb 2014 20:20:15 -0800 (PST)
Message-ID: <20140204.202015.1497580539167714407.davem@davemloft.net>
References: <1391470390-31569-1-git-send-email-jcmvbkbc@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-xtensa@linux-xtensa.org, netdev@vger.kernel.org,
	chris@zankel.net, marc@cadence.com, ben@decadent.org.uk,
	f.fainelli@gmail.com
To: jcmvbkbc@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344AbaBEEUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 23:20:16 -0500
In-Reply-To: <1391470390-31569-1-git-send-email-jcmvbkbc@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Max Filippov <jcmvbkbc@gmail.com>
Date: Tue,  4 Feb 2014 03:33:08 +0400

> Hello David, Ben, Florian, Chris and everybody,
> 
> this series improves ethoc behavior in gigabit environment:
> - first patch disables gigabit advertisement in the attached PHY making
>   possible to use gigabit link without any additional setup;
> - second patch adds support to set up MII management bus frequency, adding
>   new fields to platform data and to OF bindings.
> 
> These changes allow to use KC-705 board with 50MHz xtensa core and OpenCores
> 10/100 Mbps MAC connected to gigabit network without any additional setup.

Both patches applied, thanks.
