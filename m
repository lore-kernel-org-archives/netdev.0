From: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Subject: Re: [PATCH] iwlwifi: iwl-agn.h included twice
Date: Wed, 15 Feb 2012 08:50:09 -0800
Message-ID: <1329324609.7290.67.camel@wwguy-huron>
References: <1329328516-4792-1-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, Danny Kukawka <dkukawka@suse.de>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329328516-4792-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-02-15 at 18:55 +0100, Danny Kukawka wrote:
> drivers/net/wireless/iwlwifi/iwl-core.c included 'iwl-agn.h' twice,
> remove the duplicate.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
Acked-by: Wey-Yi Guy <wey-yi.w.guy@intel.com>
