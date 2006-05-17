From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 0/5] sky2 bugfixes for 2.6.17
Date: Wed, 17 May 2006 14:37:02 -0700
Message-ID: <20060517213702.322762000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:46520 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751149AbWEQVlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 May 2006 17:41:23 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set of bug fixes to address issues on dual port cards, and
the new Yukon Ultra used on many vendors new dual core laptops.

Since Linus seems to have ignored the last sky2 patch, this
set is based on 2.6.17-rc4 latest.

--

