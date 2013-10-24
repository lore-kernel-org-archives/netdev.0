From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/5 NEXT V2] staging: r8188eu: Fix sparse warnings.
Date: Wed, 23 Oct 2013 22:31:32 -0500
Message-ID: <1382585497-6787-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

This set of patches resubmits the set of fixes for sparse warnings. The two that
were criticized have been removed, and this set should not have white-space
damage.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>


Larry Finger (5):
  staging: r8188eu: Fix sparse warnings in ioctl_linux.c
  staging: r8188eu: Fix sparse warnings in rtw_ieee80211.c
  staging: r8188eu: Fix sparse warnings in rtl8188e.cmd.c
  staging: r8188eu: Fix sparse warnings in rtw_mlme_ext.c
  staging: r8188eu: Fix sparse warnings in rtl_p2p.c

 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c  | 41 +++++++++++++-------------
 drivers/staging/rtl8188eu/core/rtw_p2p.c       |  8 ++---
 drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c   |  8 ++---
 drivers/staging/rtl8188eu/include/ieee80211.h  | 16 +++++-----
 drivers/staging/rtl8188eu/os_dep/ioctl_linux.c | 20 ++++++-------
 6 files changed, 47 insertions(+), 46 deletions(-)

-- 
1.8.4
