From: "Tjernlund" <tjernlund@tjernlund.se>
Subject: Patches not in Linus tree yet
Date: Fri, 29 Dec 2006 21:03:15 +0100
Message-ID: <00f001c72b84$6205c050$1e67a8c0@Jocke>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from csmtp.b-one.net ([195.47.247.21]:55742 "EHLO csmtp1.b-one.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965144AbWL2U1Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Dec 2006 15:27:25 -0500
Received: from Jocke (84-217-7-200.tn.glocalnet.net [84.217.7.200])
	by csmtp1.b-one.net (Postfix) with ESMTP id DF6F419115583
	for <netdev@vger.kernel.org>; Fri, 29 Dec 2006 21:03:19 +0100 (CET)
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These two patches aren't in Linus tree yet:
http://ozlabs.org/pipermail/linuxppc-dev/2006-December/029247.html
http://ozlabs.org/pipermail/linuxppc-dev/2006-December/029248.html

They really need be in next release since mpx83xx ucc_geth driver
wont compile otherwise.

