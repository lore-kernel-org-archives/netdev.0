From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 0/5] qlge: Warning fixes and cleanup.
Date: Fri, 9 Jan 2009 13:30:45 -0800
Message-ID: <20090109213045.GD10803@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	linux-driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:58103 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756265AbZAIVax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 16:30:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

This series includes the change from volatile to rmb() usage that you
asked for from the last set of patches.  I've also included a warning
fix and some clean up.

Regards,
Ron Mercer
