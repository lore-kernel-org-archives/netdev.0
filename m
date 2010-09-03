From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [PATCH net-next] ns83820: Minor ethtool stuff and some cleanups
Date: Fri,  3 Sep 2010 20:05:38 +0000
Message-ID: <1283544341-18532-1-git-send-email-dkirjanov@hera.kernel.org>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:42785 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757317Ab0ICUFq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Sep 2010 16:05:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some ethtool stuff for the ns83820:
1/3 Remove unused have_optical variable.
2/3 Add copper device settings
3/3 Use predefined autoneg constants

Regards,
	Denis
