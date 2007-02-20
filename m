From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 0/3] chelsio 10G driver cleanups
Date: Tue, 20 Feb 2007 15:57:59 -0800
Message-ID: <20070220235759.102686172@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:56877 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161107AbXBTX7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 18:59:43 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some janitorial type house cleaning of the Chelsio 10G driver.
Remove dead code spotted by Adrian and make iniatialization
logic clearer.
-- 

