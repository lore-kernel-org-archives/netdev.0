From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH 0/4] enic: review updates and bug fixes
Date: Wed, 24 Sep 2008 11:23:08 -0700
Message-ID: <20080924182154.22778.76605.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:1170 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbYIXSYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 14:24:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

The following series implements...

 - don't indicate IPv6 pkts using soft-LRO
 - fixes for review items from Ben Hutchings
 - bug fix: Free MSI intr with correct data handle
 - bug fix: don't set netdev->name too early

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
