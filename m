From: Eugene Konev <ejka@imfi.kspu.ru>
Subject: [PATCH 0/0] cpmac: update to the net subsystem changes
Date: Wed, 24 Oct 2007 10:42:00 +0800
Message-ID: <1193193723-12691-1-git-send-email-ejka@imfi.kspu.ru>
Cc: Matteo Croce <technoboy85@gmail.com>, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 117.19.65.80.ip.morning.ru ([80.65.19.117]:54704 "EHLO
	mail.imfi.kspu.ru" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753460AbXJXDBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 23:01:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset includes cpmac updates for changed net subsystem interfaces.
Please accept the following patches for cpmac driver:
  1. cpmac: use print_mac() instead of MAC_FMT
  2. cpmac: convert to napi_struct interface
  3. cpmac: update to new fixed phy driver interface
