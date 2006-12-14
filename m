From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 0/4] network device interface cleanups
Date: Thu, 14 Dec 2006 12:48:14 -0800
Message-ID: <20061214204814.631279000@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:56858 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751596AbWLNUwi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 15:52:38 -0500
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This set of patches makes softnet_data local to dev.c and
does some code cleanups, no API changes.

-- 

