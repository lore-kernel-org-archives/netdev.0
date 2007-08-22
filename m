From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [00/10] pasemi_mac patches for 2.6.24
Date: Wed, 22 Aug 2007 09:12:37 -0500
Message-ID: <20070822141237.GA16830@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
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

pasemi_mac patches for 2.6.24:

01/10: pasemi_mac: Abstract out register access
02/10: pasemi_mac: Stop using the pci config space accessors for register read/writes
03/10: pasemi_mac: Enable L2 caching of packet headers
04/10: pasemi_mac: Fix memcpy amount for short receives
05/10: pasemi_mac: RX performance tweaks
06/10: pasemi_mac: Batch up TX buffer frees
07/10: pasemi_mac: Enable LLTX
08/10: pasemi_mac: Fix TX ring wrap checking
09/10: pasemi_mac: Fix RX checksum flags
10/10: pasemi_mac: Clean TX ring in poll


Thanks,

Olof

--
