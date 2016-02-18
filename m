From: Robert Richter <rrichter@caviumnetworks.com>
Subject: [PATCH 0/2] net: thunderx: Small cleanups
Date: Thu, 18 Feb 2016 13:39:07 +0100
Message-ID: <1455799149-19590-1-git-send-email-rrichter@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Robert Richter <rric@kernel.org>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>,
 Sunil Goutham <sgoutham@cavium.com>, linux-arm-kernel@lists.infradead.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Robert Richter <rrichter@cavium.com>

Sending two small cleanups of the driver fixing issues found during
code review.

Robert Richter (2):
  net: thunderx: Fix const type in nicvf_set_rxfh()
  net, thunderx: Use bool in structs where possible

 drivers/net/ethernet/cavium/thunder/nic.h           | 12 ++++++------
 drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c |  2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

-- 
2.7.0.rc3
