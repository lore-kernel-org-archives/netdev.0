From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 0/14 net-next] more TIPC fixes and updates
Date: Tue, 17 Aug 2010 17:00:02 -0400
Message-ID: <1282078816-11844-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:57109 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057Ab0HQVAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 17:00:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With net-next reopened, here is another batch of TIPC patches primarily
from the out-of-kernel repo.  There is no real binding between any of the
commits aside from taking what appear to be stand-alone bits and migrating
them across and fixing up minor coding style things etc.  I believe there
will be a chance to get a lot more of this done in this dev window, so
hopefully this will be just one batch of several that I end up sending.

Basic runtime sanity test done on v2.6.36-rc1, and all patches git am
cleanly on the net-next of today as well.

Thanks,
Paul.

