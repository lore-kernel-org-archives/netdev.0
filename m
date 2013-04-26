From: Petko Manolov <petkan@nucleusys.com>
Subject: [PATCH 0/3] drivers: net: usb: pegasus: bug fixing and cleanup
Date: Fri, 26 Apr 2013 10:13:41 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1304261008410.3772@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Petko Manolov <petkan@nucleusys.com>

This series of patches is fixing a bug related to multiple control URB 
submissions (noted by Sarah Sharp), optimizes read and write_mii_word 
routines and removes socket buffer pool used in the receive path.

Signed-off-by: Petko Manolov <petkan@nucleusys.com>
