From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.25 0/2] RDMA/cxgb3 patches for 2.6.25
Date: Mon, 26 Nov 2007 11:24:57 -0600
Message-ID: <20071126172457.22792.62583.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, jeff@garzik.org, ewg@lists.openfabrics.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
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

Hey roland,

Please pull these two iw_cxgb3 patches for 2.6.25.  The 5.0 firmware
change must be committed along with the cxgb3 NIC changes submitted here:

http://lkml.org/lkml/2007/11/16/224

and merged by Jeff here:

http://lkml.org/lkml/2007/11/23/180


Shortlog:

      RDMA/cxgb3: Hold rtnl_lock() around ethtool get_drvinfo call.
      RDMA/cxgb3: Support 5.0 firmware.

---

Steve.
