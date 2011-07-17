From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] ath6kl: more neatening
Date: Sun, 17 Jul 2011 14:38:55 -0700
Message-ID: <cover.1310938421.git.joe@perches.com>
References: <4E2349D4.4000204@qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregkh@suse.de, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <4E2349D4.4000204@qca.qualcomm.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Sender: devel-bounces@linuxdriverproject.org
Errors-To: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

> Great, thanks. I have now applied your patches to ath6kl-cleanup tree
> and they will be included in patchset v3.

Here's a couple of more.

Joe Perches (2):
  ath6kl: Remove __func__ uses from ath6kl_dbg
  ath6kl: Remove trailing unpaired close paren from ath6kl_err uses

 drivers/net/wireless/ath/ath6kl/bmi.c      |    4 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c |  101 ++++++++++++---------------
 drivers/net/wireless/ath/ath6kl/debug.c    |   20 +++---
 drivers/net/wireless/ath/ath6kl/debug.h    |   27 ++++----
 drivers/net/wireless/ath/ath6kl/htc.c      |   11 ++--
 drivers/net/wireless/ath/ath6kl/init.c     |    8 +-
 drivers/net/wireless/ath/ath6kl/main.c     |   13 ++--
 drivers/net/wireless/ath/ath6kl/sdio.c     |   12 ++--
 drivers/net/wireless/ath/ath6kl/txrx.c     |   30 ++++-----
 drivers/net/wireless/ath/ath6kl/wmi.c      |    8 +--
 10 files changed, 107 insertions(+), 127 deletions(-)

-- 
1.7.6.131.g99019
