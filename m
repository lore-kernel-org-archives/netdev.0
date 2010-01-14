From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 0/4] netxen: endianness fixes
Date: Thu, 14 Jan 2010 02:43:03 -0800
Message-ID: <1263465787-28203-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:56163 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755967Ab0ANKnK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2010 05:43:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
  Series of 4 small patches to fix endianness issues and License header.
  These issues were suggested by Ben Hutchings for qlcnic driver,
  same apply to netxen_nic driver.
  Please apply these patches in net-2.6 tree.

-Amit Salecha
