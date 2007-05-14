From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 0/6] more sky2 patches for 2.6.22
Date: Mon, 14 May 2007 12:38:09 -0700
Message-ID: <20070514193809.867470364@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:46332 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754537AbXENTmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 15:42:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These are less serious than the last group, and are mostly
one liners.  I decided to give up blacklisting the 88e8056
problem in the driver, if the driver can't identify what configuration
is good/bad, then it has no business trying to enforce the policy.


--
Stephen Hemminger <shemminger@linux-foundation.org>

