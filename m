From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next PATCH 0/3] Energy Efficient Ethernet (eee) support
Date: Tue, 5 Jun 2012 09:38:59 +0300
Message-ID: <1338878342-24586-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, peppe.cavallaro@st.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3480 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751161Ab2FEGkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 02:40:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series adds energy efficient ethernet support for the
bnx2x driver (for new chips with appropriate phys). 
It also extends the ethtool API to enable control of the eee feature.

Another patch series has been sent to Ben to allow the ethtool application
to use this new API.

Please consider applying it to 'net-next'.

Thanks,
Yuval Mintz
