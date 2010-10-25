From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 0/1] ipv6 POSTDAD fix
Date: Mon, 25 Oct 2010 11:06:42 +0200
Message-ID: <20101025090642.958260964@linux.vnet.ibm.com>
Cc: vosburgh@de.ibm.com
To: netdev@vger.kernel.org, linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.17.164]:51643 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708Ab0JYJHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 05:07:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

running into a refcnt problem with a bond device,
I propose this patch to solve it.

Regards, Ursula

