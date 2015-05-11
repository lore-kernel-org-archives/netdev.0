From: Okash Khawaja <okash.khawaja@gmail.com>
Subject: [PATCH v2 0/2] adm8211 patches
Date: Mon, 11 May 2015 12:41:04 +0100
Message-ID: <20150511114104.GA4985@bytefire-computer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches include two changes:

1. Code cleanup around a switch-case statement
2. Bug fix for the possible PCI cache line sizes

Okash Khawaja (2):
  adm8211: fix checkpatch errors for indentation and new line.
  adm8211: fixed the possible pci cache line sizes inside switch-case

 drivers/net/wireless/adm8211.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

-- 
2.4.0
