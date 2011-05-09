From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH 1/2] linux-firmware: update firmware for RTL8111E
Date: Mon, 09 May 2011 09:23:44 +0100
Message-ID: <1304929425.12237.15.camel@i7.infradead.org>
References: <1304928149-2201-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:44839 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070Ab1EIIXr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 04:23:47 -0400
In-Reply-To: <1304928149-2201-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-09 at 16:02 +0800, Hayes Wang wrote:
> Updated firmware with stability fixes.

Applied.; thanks.

I'd be a lot happier if the WHENCE file contained version numbers. Does
the *driver* print a version string for the firmware after loading it?

-- 
dwmw2

