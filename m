From: frank.blaschka@de.ibm.com
Subject: [patch 0/6] [resend] s390: network patches for net-next
Date: Wed, 02 Feb 2011 17:04:30 +0100
Message-ID: <20110202160430.554090958@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([194.196.100.167]:52492 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754396Ab1BBQFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 11:05:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I have removed the NET_SKB_PAD patch from the patch set.
We will define it in an arch specific header. The new
version of the patch will come via the s390 tree. Thx!

shortlog:
Ursula Braun (3)
qeth: show new mac-address if its setting fails
qeth: allow HiperSockets framesize change in suspend
qeth: allow OSA CHPARM change in suspend state

Frank Blaschka (1)
qeth: add more strict MTU checking

Stefan Weil (2)
s390: Fix wrong size in memcmp (netiucv)
s390: Fix possibly wrong size in strncmp (smsgiucv)

Thanks,
        Frank

