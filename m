From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 00/12] [PATCHSET] RTNetlink message handler registration interface
Date: Wed, 21 Mar 2007 01:05:53 +0100
Message-ID: <20070321000553.070942307@lsx.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44401 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751592AbXCUAmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 20:42:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduces an interface to register rtnetlink message handlers
and converts all users of rtnl_links[].

