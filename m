From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH v3] stmmac: improve logging
Date: Thu,  5 Nov 2015 09:30:04 +0100
Message-ID: <1446712209-28890-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hello

This patch series try to improve logging of the stmmac driver.

Changes since v2
- Rollback to dev_ for some early init printing
- rebased on 4.4-rc1

Changes since v1
- Use netdev_xxx instead of dev_xxx
- Use netif_xxx instead of "if (netif_msg_type) dev_xxx"
Regards
