From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] arm: convert omap ldp platform to use smsc911x
Date: Mon, 19 Jan 2009 16:30:50 -0800 (PST)
Message-ID: <20090119.163050.119999958.davem@davemloft.net>
References: <1232010482-3744-5-git-send-email-steve.glendinning@smsc.com>
	<1232010482-3744-6-git-send-email-steve.glendinning@smsc.com>
	<20090119223541.GK18301@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	stanley.miao@windriver.com, ian.saturley@smsc.com
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60507
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755642AbZATAas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 19:30:48 -0500
In-Reply-To: <20090119223541.GK18301@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Mon, 19 Jan 2009 22:35:41 +0000

> davem - I can see if I merge a fix for this (once I have confirmation
> what the fix should be) and push it for -rc, that will make things a
> little more complicated at your end.  Suggest we hold fire on these
> patches for a few more days.

Ok, I'm going to toss the smsc911x patches from my tree as well.

Just resubmit to me and netdev@vger the relevant parts I should take
in my tree once this is all sorted out.

Thanks!
