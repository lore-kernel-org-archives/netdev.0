From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 00/12] [RESEND] rtnetlink message handler registration interface
Date: Thu, 22 Mar 2007 13:59:55 +0100
Message-ID: <20070322125955.055083236@lsx.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:53622 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750735AbXCVNBZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 09:01:25 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The existing function names seem to have sentimental value to some
people. Same patches but without changes to the functio names.

Introduces an interface to register rtnetlink message handlers
and converts all users of rtnl_links[].

