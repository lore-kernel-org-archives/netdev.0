From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/2] linux-firmware: update firmware for RTL8111E
Date: Mon, 9 May 2011 21:23:09 +0200
Message-ID: <20110509192309.GA20763@electric-eye.fr.zoreil.com>
References: <1304928149-2201-1-git-send-email-hayeswang@realtek.com> <1304929425.12237.15.camel@i7.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57889 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753555Ab1EITct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 15:32:49 -0400
Content-Disposition: inline
In-Reply-To: <1304929425.12237.15.camel@i7.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse <dwmw2@infradead.org> :
[...]
> I'd be a lot happier if the WHENCE file contained version numbers. Does
> the *driver* print a version string for the firmware after loading it?

No.

Hayes, do we agree that the firmware needs to embed a version identifier (and
some checksum to identify the current firmware that don't embed one).

-- 
Ueimor
