From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH 0/4] OpenCores 10/100 MAC ethtool operations
Date: Wed, 29 Jan 2014 23:56:33 +0400
Message-ID: <1391025397-14965-1-git-send-email-jcmvbkbc@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Marc Gauthier <marc@cadence.com>,
	Max Filippov <jcmvbkbc@gmail.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David, Florian and everybody,

this series implements ethtool callbacks for the ethoc driver as was
requested by Florian.

Max Filippov (4):
  net: ethoc: implement basic ethtool operations
  net: ethoc: implement ethtool get/set settings
  net: ethoc: implement ethtool get registers
  net: ethoc: implement ethtool get/set ring parameters

 drivers/net/ethernet/ethoc.c | 85 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 85 insertions(+)

-- 
1.8.1.4
