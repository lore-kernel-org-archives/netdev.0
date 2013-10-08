From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next v2 0/5] xen-netback: IPv6 offload support
Date: Tue, 8 Oct 2013 11:58:11 +0100
Message-ID: <1381229896-18657-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:44908 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756012Ab3JHK6T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Oct 2013 06:58:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for checksum and large packet offloads into
xen-netback.
Testing has mainly been done using the Microsoft network hardware
certification suite running in Server 2008R2 VMs with Citrix PV frontends.

v2:
- Fixed Wei's email address in Cc lines
