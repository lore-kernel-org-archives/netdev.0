From: Chris Paterson <chris.paterson2@renesas.com>
Subject: [PATCH v2 0/2] can: Add r8a7796 support to CAN/CAN FD
Date: Thu, 24 Nov 2016 16:11:55 +0000
Message-ID: <1480003917-3953-1-git-send-email-chris.paterson2@renesas.com>
References: <1479903243-1860-1-git-send-email-chris.paterson2@renesas.com>
Cc: Wolfgang Grandegger <wg@grandegger.com>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Geert Uytterhoeven <geert+renesas@glider.be>,
        Simon Horman <horms@verge.net.au>,
        Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        Chris Paterson <chris.paterson2@renesas.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor4.renesas.com ([210.160.252.174]:37251 "EHLO
        relmlie3.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752330AbcKXQMF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 11:12:05 -0500
In-Reply-To: <1479903243-1860-1-git-send-email-chris.paterson2@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds support for r8a7796 to rcar_can and rcar_canfd.

Original series: [PATCH 0/3] arm64: dts: r8a7796: Add CAN/CAN FD support.

Changes since v1:
- Split bindings documentation changes from device tree changes.
- Rebased on renesas-devel-20161123v2-v4.9-rc6.


Chris Paterson (2):
  can: rcar_can: Add r8a7796 support
  can: rcar_canfd: Add r8a7796 support

 Documentation/devicetree/bindings/net/can/rcar_can.txt   | 12 +++++++-----
 Documentation/devicetree/bindings/net/can/rcar_canfd.txt | 12 +++++++-----
 2 files changed, 14 insertions(+), 10 deletions(-)

-- 
1.9.1
