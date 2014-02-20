From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 00/14 v2] 05/14 respun.
Date: Wed, 19 Feb 2014 19:49:37 -0800
Message-ID: <1392868178-7011-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35441 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752831AbaBTDwm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 22:52:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 05/14 of the series was updated to address concerns from Joe Perches.
The rest of the series remains the same.

Mitch Williams (1):
  05/14 v2 i40evf: fix up strings in init task

 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 36 +++++++++++--------------
 1 file changed, 16 insertions(+), 20 deletions(-)

-- 
1.8.5.GIT
