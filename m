From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 0/8] qlge: Add firmware coredump functionality.
Date: Mon, 11 Jan 2010 17:12:57 -0800
Message-ID: <1263258785-5112-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:47619 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753067Ab0ALBTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 20:19:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Dump all regsiters and on chip RAM when a fatal firmware error is
encountered.  This features is turn on by default but can be
turned off with a module parameter.

