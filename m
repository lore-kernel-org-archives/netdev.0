From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 0/3] chelsio driver changes
Date: Fri, 15 Dec 2006 11:07:16 -0800
Message-ID: <20061215190716.956791000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:36134 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753227AbWLOTLQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 14:11:16 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One error path bug fix, and a couple of changes to improve
receive performance.  The performance is now up to 5+ Gbits/sec
which is about the limit of the memory/bus on the test systems.


