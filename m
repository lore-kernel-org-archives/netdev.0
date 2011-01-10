From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 0/3]qlcnic:bug fixes
Date: Mon, 10 Jan 2011 02:15:20 -0800
Message-ID: <1294654523-3085-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:5271 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753341Ab1AJKPl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 05:15:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,
  Series of 3 patches to fix bugs. Apply them on net-2.6.

  Driver is reading incorrect flash fw version and fails to load, 
  "fix flash fw version read" patch fixes this.

-Amit
