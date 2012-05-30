From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] iwlwifi: fix typo 'IWL_WATCHHDOG_DISABLED'
Date: Wed, 30 May 2012 09:18:08 +0200
Message-ID: <1338362288.4511.7.camel@jlt3.sipsolutions.net>
References: <1338361709.1780.3.camel@x61.thuisdomein>
	 (sfid-20120530_091345_630175_CC635231)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338361709.1780.3.camel@x61.thuisdomein> (sfid-20120530_091345_630175_CC635231)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-05-30 at 09:08 +0200, Paul Bolle wrote:
> Commit 7c5ba4a830cbb730770129b0004e2a06e47dbac5 ("iwlwifi: move queue
> watchdog into transport") introduced the named constant
> 'IWL_WATCHHDOG_DISABLED'. Rename it to 'IWL_WATCHDOG_DISABLED'.

Thanks, I've picked this up. Since we're in the merge window John isn't
taking new patches right now so it'll be a while until it shows up.

johannes
