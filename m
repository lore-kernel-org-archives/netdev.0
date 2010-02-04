From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 00/23 v3] mlx4: multi-function framework and Ethernet SRIOV
Date: Thu, 04 Feb 2010 17:54:12 +0200
Message-ID: <4B6AEDA4.7080603@mellanox.co.il>
References: <49BFC313.1030901@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: general@lists.openfabrics.org, netdev@vger.kernel.org,
	liranl@mellanox.co.il, tziporet@mellanox.co.il
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:46804 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932552Ab0BDPyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2010 10:54:16 -0500
In-Reply-To: <49BFC313.1030901@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Roland,

This is the third version of these patches, the main changes from previous time:
1. ConnectX-2 HW support.
2. The master function raises interfaces as well.
3. Using HCR completion interrupts for the master function.
4. Multicast fixes.
5. Removed bitmap allocation wrapper.

Thanks,
Yevgeny
