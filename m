From: Sebastian Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH / RFC 0/2] spinlocks fixup in fec / m68knommu driver
Date: Wed, 02 Apr 2008 13:28:21 +0200
Message-ID: <47F36DD5.20902@linutronix.de>
References: <20080327140041.072611004@linutronix.de> <47EC9577.2090402@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: uclinux-dev@uclinux.org, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
To: Greg Ungerer <gerg@snapgear.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:35580 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752846AbYDBLXI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Apr 2008 07:23:08 -0400
In-Reply-To: <47EC9577.2090402@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg Ungerer wrote:
> Hi Sebastion,
s/o/a :)

> No, it looks broken :-(
I'm going to post a cleanup patch and a locking fixup patch. The missing 
lock is more serious than I though in first place.

> Regards
> Greg
Sebastian
