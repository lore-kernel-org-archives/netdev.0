From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: [PATCH 0/2] can: pch_can: fix sparse warnings and section mismatch
Date: Wed, 27 Oct 2010 10:38:24 +0200
Message-ID: <1288168706-870-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

this patch fixes two problems found during compile time, a sparse warning
and a section mismatch.

These patches apply to net-2.6/master

cheers, Marc

---

The following changes since commit 7a876b0efcba3804da3051313445fa7be751cab7:

  IPv6: Temp addresses are immediately deleted. (2010-10-26 12:35:13 -0700)

are available in the git repository at:
  git://git.pengutronix.de/git/mkl/linux-2.6.git can/pch_can-for-net-2.6

Marc Kleine-Budde (2):
      can: pch_can: fix sparse warning
      can: pch_can: fix section mismatch warning by using a whitelisted name

 drivers/net/can/pch_can.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)
