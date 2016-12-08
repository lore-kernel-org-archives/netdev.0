From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Remove private tx queue locks
Date: Fri,  9 Dec 2016 00:55:41 +0100
Message-ID: <1481241343-18062-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: romieu@fr.zoreil.com, pavel@ucw.cz, davem@davemloft.net,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this patch series removes unnecessary private locks in the sxgbe and the
stmmac driver.

v2:
- adjust commit message
