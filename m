From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 0/2] sctp: Crash fixes.
Date: Mon,  2 Mar 2009 11:46:49 -0500
Message-ID: <1236012411-17841-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:46104 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184AbZCBQq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 11:46:59 -0500
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi David

There two patches fix crashes in the sctp module.  The module-unload
one is actually a regression from as far back as 2.6.25.

The second one could be classified as a potential security issue.

Thanks
-vlad
