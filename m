From: Masakazu Mokuno <mokuno@sm.sony.co.jp>
Subject: [PATCH 0/6] PS3: gelic: gelic updates for 2.6.25
Date: Thu, 13 Dec 2007 19:38:28 +0900
Message-ID: <20071213181146.BF69.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux/PPC Development <linuxppc-dev@ozlabs.org>
To: netdev@vger.kernel.org
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

	Hi,

Here is a set of updates for PS3 gelic network driver.
This patch set requires other patches which were already submitted by
Geert (http://marc.info/?l=linux-kernel&m=119626095605487).

	[1] PS3: gelic: Fix the wrong dev_id passed
	[2] PS3: gelic: Add endianness macros
	[3] PS3: gelic: Code cleanup
	[4] PS3: gelic: Remove duplicated ethtool handers
	[5] PS3: gelic: Add support for port link status
	[6] PS3: gelic: Add support for dual network interface

This is also a set of prerequisite for new wireless driver for PS3, which
I'll submit later. 

Thanks for reviewing!

-- 
Masakazu MOKUNO
