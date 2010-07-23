From: frank.blaschka@de.ibm.com
Subject: [patch 0/8] s390: qeth some more patches for 2.6.36
Date: Fri, 23 Jul 2010 11:15:02 +0200
Message-ID: <20100723091502.678949000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:43291 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753468Ab0GWJPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 05:15:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

this is the second patch set (qeth + 1 claw) for 2.6.36 (net-next).

shortlog:
Klaus Wacker (1)
qeth: IP address takeover flag setting

Ursula Braun (5)
qeth: serialize sysfs-triggered device configurations
qeth: avoid loop if ipa command response is missing
claw: A claw device is a group of just 2 ccw devices
qeth: return zero from reply callback functions
qeth: avoid useless removal of multicast addresses

Julia Lawall (1)
qeth: Use memdup_user when user data is immediately copied into the allocated region.

Carsten Otte (1)
qeth: Clear mac_bits field when switching between Layer 2 and Layer 3

Thanks,
        Frank
