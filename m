From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: stmmac: improve logging
Date: Thu, 10 Sep 2015 14:37:28 +0200
Message-ID: <1441888653-30535-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	joe@perches.com
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello

This patch series try to improve logging of the stmmac driver.

Changes since v1
- Use netdev_xxx instead of dev_xxx
- Use netif_xxx instead of "if (netif_msg_type) dev_xxx"

Regards
