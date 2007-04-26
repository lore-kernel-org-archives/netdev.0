From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.22 5/5] iw_cxgb3: Update required firmware
	revision to 4.0.0.
Date: Thu, 26 Apr 2007 15:21:26 -0500
Message-ID: <20070426202126.24234.71523.stgit@dell3.ogc.int>
References: <20070426202057.24234.56383.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org, divy@chelsio.com,
	linux-kernel@vger.kernel.org
To: rdreier@cisco.com,jeff@garzik.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070426202057.24234.56383.stgit@dell3.ogc.int>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


Update required firmware revision to 4.0.0.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/net/cxgb3/version.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb3/version.h b/drivers/net/cxgb3/version.h
index 042e27e..b112317 100644
--- a/drivers/net/cxgb3/version.h
+++ b/drivers/net/cxgb3/version.h
@@ -38,7 +38,7 @@ #define DRV_NAME "cxgb3"
 #define DRV_VERSION "1.0-ko"
=20
 /* Firmware version */
-#define FW_VERSION_MAJOR 3
-#define FW_VERSION_MINOR 3
+#define FW_VERSION_MAJOR 4
+#define FW_VERSION_MINOR 0
 #define FW_VERSION_MICRO 0
 #endif				/* __CHELSIO_VERSION_H */
