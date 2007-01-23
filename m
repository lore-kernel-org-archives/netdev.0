From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 23 Jan 2007 00:36:46 -0500
Message-ID: <45B59EEE.2040002@garzik.org>
References: <20070118154801.GB31580@tuxdriver.com> <20070118154906.GC31580@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45291 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933004AbXAWFgv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 00:36:51 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20070118154906.GC31580@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> The following changes since commit 10764889c6355cbb335cf0578ce12427475d1a65:
>   Larry Finger (1):
>         bcm43xx: Fix failure to deliver PCI-E interrupts
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream
> 
> Daniel Drake (6):
>       zd1211rw: Generic HMAC initialization
>       zd1211rw: 2 new ZD1211B device ID's
>       zd1211rw: Consistency for address space constants
>       zd1211rw: Remove addressing abstraction
>       zd1211rw: Add ID for Linksys WUSBF54G
>       zd1211rw: Add ID for ZyXEL ZyAIR G-220 v2
> 
> John W. Linville (1):
>       softmac: avoid assert in ieee80211softmac_wx_get_rate
> 
> Kai Engert (1):
>       prism54: add ethtool -i interface
> 
> Larry Finger (1):
>       bcm43xx: Interrogate hardware-enable switch and update LEDs
> 
> Michael Buesch (1):
>       Update Prism54 MAINTAINERS entry
> 
> Zhu Yi (1):
>       ipw2200: add iwconfig rts/frag auto support

pulled, thanks


