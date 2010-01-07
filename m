From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv3 NEXT 0/2]qlcnic: Add Qlogic ethernet driver for CNA devices
Date: Thu,  7 Jan 2010 04:35:10 -0800
Message-ID: <1262867712-32519-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:43788 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752174Ab0AGMfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 07:35:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
  This is the fixed patch series v3. This addresses Stephen's comment.

  -Using kmalloc for tx buffers.
  -Using mutex for mem_lock
  -Some minor const and static fix.

  Plz discard v2 patches.

-Amit Salecha	
