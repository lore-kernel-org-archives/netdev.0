From: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Subject: Re: [Patch] iwlwifi: remove obsoleted module alias and parameters
Date: Wed, 06 Apr 2011 07:05:55 -0700
Message-ID: <1302098755.14995.112.camel@wwguy-huron>
References: <1302083382-6715-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	"Venkataraman, Meenakshi" <meenakshi.venkataraman@intel.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31294 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756249Ab1DFOZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 10:25:08 -0400
In-Reply-To: <1302083382-6715-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-06 at 02:49 -0700, Amerigo Wang wrote:
> As scheduled in Documentation/feature-removal-schedule.txt,
> remove "*50", "disable_hw_scan" module parameters and MODULE_ALIAS("iwl4965").
> 
> Cc: Intel Linux Wireless <ilw@linux.intel.com>
> Cc: Johannes Berg <johannes.berg@intel.com>
> Cc: "John W. Linville" <linville@tuxdriver.com>
> Cc: Wey-Yi Guy <wey-yi.w.guy@intel.com> 
> Cc: Stanislaw Gruszka <sgruszka@redhat.com>
> Cc: Meenakshi Venkataraman <meenakshi.venkataraman@intel.com>
> Cc: Larry Finger <Larry.Finger@lwfinger.net>
> Signed-off-by: WANG Cong <amwang@redhat.com>
> 
> ---
what tree you are base on?
please check commit#7eaa6a5e964f1ab02d849bda36950c0d30be8ce2 in
wireless-next-2.6

Thanks
Wey


