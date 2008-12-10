From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: b43 phy0 error
Date: Wed, 10 Dec 2008 09:22:57 -0500
Message-ID: <20081210142257.GB5168@tuxdriver.com>
References: <20081210003948.24694199B271@f14.poczta.interia.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: siamer <siamer@interia.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38772 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbYLJOaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 09:30:13 -0500
Content-Disposition: inline
In-Reply-To: <20081210003948.24694199B271@f14.poczta.interia.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 10, 2008 at 01:39:47AM +0100, siamer wrote:
> Hi i have broadcom 4318 wireless card (laptop asus a6km) when i'm
> using firmware from linuxwiereless.com (4.150.10.5) then internet is
> working but when i'm starting download something than is disconnecting
> me. dmesg show : b43 phy0 error
> I tryed that on few different distros and on different kernels
> (2.6.25 2.6.26 2.6.27 wireless-testing and compact-wireless) is the
> same... PLEASE HELP ME... Why is like that ?

This is one of the nagging mysteries of the BCM43xx hardware -- we
don't know what causes it.  Can you reliably recreate the problem?
If so, perhaps you can use wireshark with another wireless device in
monitor mode to capture a trace of what is happening?

John

P.S.  You probably should be sending stuff to
linux-wireless@vger.kernel.org instead.
-- 
John W. Linville		Linux should be at the core
linville@tuxdriver.com			of your literate lifestyle.
