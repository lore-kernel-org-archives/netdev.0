From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH] sctp: rfc conformance fixes
Date: Tue, 21 Oct 2008 22:08:43 -0400
Message-ID: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:31772 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412AbYJVCIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 22:08:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

The following series is a set of conformance fixes from Wei Yongjun.
One of them addresses a small bug in pmtu process, and the other three
make the shutdown process conform to the latest spec.

Please apply.

Thanks
-vlad
