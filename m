From: amit.salecha@qlogic.com
Subject: [PATCHv2 NEXT 0/2]net: external loopback suport in ethtool
Date: Wed, 29 Jun 2011 23:00:48 -0700
Message-ID: <1309413650-15952-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	sucheta.chakraborty@qlogic.com
To: davem@davemloft.net, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:53594 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1753254Ab1F3GJO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2011 02:09:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
	Sending revised patch incorporating Ben Hutchings comment.
	Comment in kernel-doc format and adding one more flag to convey
	that driver performed the external loopback test.
-Amit
