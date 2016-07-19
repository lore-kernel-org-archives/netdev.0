From: zyjzyj2000@gmail.com
Subject: (unknown)
Date: Tue, 19 Jul 2016 21:31:52 +0800
Message-ID: <1468935113-3051-1-git-send-email-zyjzyj2000@gmail.com>
References: <F6FB0E698C9B3143BDF729DF2228664696ACAA19@ORSMSX116.amr.corp.intel.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, donald.c.skidmore@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [123.119.179.77] ([123.119.179.77]:37234 "EHLO mail.zhuyj.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752430AbcGTC4z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jul 2016 22:56:55 -0400
Subject: 
In-Reply-To: <F6FB0E698C9B3143BDF729DF2228664696ACAA19@ORSMSX116.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


v1->v2:
Follow the advice from Donald, replacing read directly from RSTD and 
RSTI register with a state variable __IXGBEVF_HW_RESETTING;
