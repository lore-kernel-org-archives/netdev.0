From: Roger Chen <roger.chen@rock-chips.com>
Subject: [PATCH 0/4] support GMAC driver for RK3288
Date: Tue, 25 Nov 2014 17:07:36 +0800
Message-ID: <1416906460-26078-1-git-send-email-roger.chen@rock-chips.com>
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	kever.yang@rock-chips.com, mark.yao@rock-chips.com,
	eddie.cai@rock-chips.com, roger.chen@rock-chips.com
To: heiko@sntech.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roger Chen (4):
  patch1: add driver for Rockchip RK3288 SoCs integrated GMAC
  patch2: modify CRU config for Rockchip RK3288 SoCs integrated GMAC
  patch3: dts: add gmac info for rk3288
  patch4: dts: enable gmac on RK3288 evb board

tested on rk3288 SDK board:
busybox ifconfig eth0 up
busybox ifconfig eth0 192.168.1.111
ping 192.168.1.1

-- 
1.7.9.5
