From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [Resend][PATCH] Wireless / ath5k: Simplify suspend and resume
	callbacks
Date: Mon, 23 Nov 2009 16:33:54 -0500
Message-ID: <20091123213353.GA9045@tuxdriver.com>
References: <200911212344.24170.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ath5k-devel@lists.ath5k.org, linux-wireless@vger.kernel.org,
	Bob Copeland <me@bobcopeland.com>,
	LKML <linux-kernel@vger.kernel.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	netdev@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@gmail.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52260 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757337AbZKWWAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 17:00:38 -0500
Content-Disposition: inline
In-Reply-To: <200911212344.24170.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 21, 2009 at 11:44:24PM +0100, Rafael J. Wysocki wrote:
> From: Rafael J. Wysocki <rjw@sisk.pl>
> Subject: Wireless / ath5k: Simplify suspend and resume callbacks
> 
> Simplify the suspend and resume callbacks of ath5k by converting the
> driver to struct dev_pm_ops and allowing the PCI PM core to do the
> PCI-specific suspend/resume handling.
> 
> Tested with Atheros Communications Inc. AR2413 802.11bg NIC (rev 01)
> D-Link CardBus.adapter.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>

This is already queued for -next.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
