From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [Patch] iwlwifi: remove obsoleted module alias and parameters
Date: Wed, 06 Apr 2011 12:09:42 +0200
Message-ID: <1302084582.3811.9.camel@jlt3.sipsolutions.net>
References: <1302083382-6715-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Meenakshi Venkataraman <meenakshi.venkataraman@intel.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:52033 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754811Ab1DFKJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 06:09:46 -0400
In-Reply-To: <1302083382-6715-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-06 at 17:49 +0800, Amerigo Wang wrote:
> As scheduled in Documentation/feature-removal-schedule.txt,
> remove "*50", "disable_hw_scan" module parameters and MODULE_ALIAS("iwl4965").

Mostly fine, but for iwlegacy Stanislaw we want to keep hw scan (and it
was actually made default now)

johannes


