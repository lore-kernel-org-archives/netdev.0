From: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Subject: Re: [PATCH] iwlagn: iwl-agn-rs: remove unnecessary null check for
 sta and lq_sta
Date: Wed, 28 Sep 2011 15:18:38 -0700
Message-ID: <1317248318.1958.21.camel@wwguy-huron>
References: <1317250444-2248-1-git-send-email-Gregory.Dietsche@cuw.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "ilw@linux.intel.com" <ilw@linux.intel.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Gregory.Dietsche@cuw.edu" <Gregory.Dietsche@cuw.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317250444-2248-1-git-send-email-Gregory.Dietsche@cuw.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-09-28 at 15:54 -0700, Gregory.Dietsche@cuw.edu wrote:
> From: Greg Dietsche <Gregory.Dietsche@cuw.edu>
> 
> both sta and lq_sta are guaranteed to be not null in the
> calling function so we don't need to check them here.
> 
> Signed-off-by: Greg Dietsche <Gregory.Dietsche@cuw.edu>
Signed-off-by: Wey-Yi Guy <wey-yi.w.guy@intel.com>
> ---
>  drivers/net/wireless/iwlwifi/iwl-agn-rs.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
you are correct

Wey
