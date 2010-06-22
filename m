From: "Divy Le Ray" <divy@chelsio.com>
Subject: [PATCH net-next-2.6 0/2] cxgb3: update FW
Date: Mon, 21 Jun 2010 18:50:55 -0700
Message-ID: <FEFB36889AE2504B92C590CE4C52B30001287983@maui.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Steve Wise" <swise@opengridcomputing.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6982 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758811Ab0FVBxA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 21:53:00 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The following 2 patch series updates cxgb3 FW to 7.10.
- patch 1/2: commit FW 7.10
- patch 2/2: Update the driver to request FW 7.10.

FW 7.10 fixes iWARP performance issues.

Cheers,
Divy

