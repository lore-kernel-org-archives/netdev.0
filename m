From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH 0/2] Ethtool: EEE support
Date: Tue, 5 Jun 2012 09:41:08 +0300
Message-ID: <1338878470-24784-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, peppe.cavallaro@st.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: bhutchings@solarflare.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1390 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751575Ab2FEGmp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2012 02:42:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

This patch series follows another series sent to net-next
which adds EEE support in the Ethtool API.

This series extends the ethtool application and allows it
to control the eee feature via the new '--get-eee' and
and '--set-eee' commands.

Thanks,
Yuval Mintz
