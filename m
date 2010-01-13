From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv4 NEXT 0/2]qlcnic: Qlogic ethernet driver for CNA devices
Date: Wed, 13 Jan 2010 02:37:24 -0800
Message-ID: <1263379046-30262-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:15472 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755734Ab0AMKhc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jan 2010 05:37:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
   This is the fixed patch series v4, incorporating Ben Hutchings suggestions.
   - Fixing License header
   - Unused #define removed
   - Using kernel defines
   - printk removed, using dev_info, dev_err and dev_warn
   - Fix : default initialization of variable
   - read mac address fixed
   - interrupt coalescing fixed

Thanks
Amit
