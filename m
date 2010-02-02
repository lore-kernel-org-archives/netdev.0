From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 0/2]netxen: tx timeout fix
Date: Tue,  2 Feb 2010 06:16:19 -0800
Message-ID: <1265120181-1671-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:52379 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756053Ab0BBOQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2010 09:16:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
  Series of 2 patches to fix tx timeout recovery and
  null pointer exception while cleaning resources.

  Plz apply these to net-2.6 tree.

Thanks
Amit Salecha
