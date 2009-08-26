From: frank.blaschka@de.ibm.com
Subject: [patch 0/5] s390: qeth patches for 2.6.32
Date: Wed, 26 Aug 2009 14:01:05 +0200
Message-ID: <20090826120105.727838000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:35315 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834AbZHZMBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 08:01:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are a couple of qeth patches for 2.6.32 (net-next).

shortlog:
Klaus-Dieter Wacker (3)
qeth: HiperSockets SIGA retry support on CC=2.
qeth: Cleanup for cast-type determination.
qeth: display service_level info only when valid.

Ursula Braun (1)
qeth: display "undefined" value of sysfs-attribute "layer2"

Frank Blaschka (1)
qeth: scheduling while atomic during ifconfig online sequence

Thanks,
        Frank
