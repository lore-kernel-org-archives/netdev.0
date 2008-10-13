From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/9] Vital Product Data (VPD) patches relating to skge/sky2
Date: Mon, 13 Oct 2008 13:13:02 -0700
Message-ID: <20081013201302.899587376@vyatta.com>
Cc: netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57902 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755579AbYJMVEN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2008 17:04:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an updated version of the patches for fixing VPD to work
with skge and sky2 (and probably other devices) with additional
timing restrictions.

Dave, please put these in for 2.6.28, they were submitted and reviewed
several times during the pre-merge cycle. Just hadn't resolved all the
comment/feedback yet.
-- 

