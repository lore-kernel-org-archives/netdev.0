From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 0/5]qlcnic: vlan rx accleration support
Date: Thu, 16 Sep 2010 06:14:27 -0700
Message-ID: <1284642872-27832-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:5444 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754717Ab0IPNOf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Sep 2010 09:14:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
   Series of 5 patch to support vlan rx accleration. Vlan rx accleration
   helps in supporting GRO and LRO on vlan interface. GRO and LRO
   support on vlan interface shows significant performance improvement and reduces 
   cpu utilization time.

-Amit
