From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCHSET] Begin of transformations to new netlink api
Date: Sat, 05 Aug 2006 02:34:52 +0200
Message-ID: <20060805003452.493542515@postel.suug.ch>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:3053 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1422673AbWHEAm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2006 20:42:59 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

First batch of patches converting existing netlink code to use
the new api. Fixing lots of unvalidated accesses to attributes.

