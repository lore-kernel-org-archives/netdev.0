From: Stephen Hemminger <shemminger@vyatta.com>
Subject: No iproute2 for 2.6.38
Date: Tue, 15 Mar 2011 19:55:34 -0700
Message-ID: <20110315195534.0cc43032@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:50024 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751391Ab1CPCzh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 22:55:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am not going to bother releasing for 2.6.38 the only changes
were later reverted.

---
Roopa Prabhu (1):
      iproute2: add VF_PORT support

Stephen Hemminger (3):
      Update to lasest kernel headers
      Revert "iproute2: add VF_PORT support"
      v2.6.38
