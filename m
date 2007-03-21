From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 0/5] [PATCHSET] Netlink Patches
Date: Wed, 21 Mar 2007 01:18:10 +0100
Message-ID: <20070321001810.616784269@lsx.localdomain>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44294 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932173AbXCUATs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2007 20:19:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Converts westwood and vegas netlink code to use the typesafe
interface, removes an unused varaible, and move some netlink
queue management code into the generic layer.

