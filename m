From: frank.blaschka@de.ibm.com
Subject: [patch 0/6] s390: qeth fixes for 2.6.30
Date: Wed, 25 Mar 2009 07:57:13 +0100
Message-ID: <20090325065713.054133000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:35182 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755254AbZCYG6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 02:58:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are a couple of qeth fixes for 2.6.30

shortlog:
Kay Sievers (1)
qeth: struct device - replace bus_id with dev_name(), dev_set_name()

Klaus-Dieter Wacker (1)
qeth: unregister MAC addresses during recovery

Ursula Braun (1)
qeth: check for completion of a running recovery

Heiko Carstens(1)
qeth: fix wait_event_timeout handling

Frank Blaschka (2)
qeth: add statistics for tx csum
qeth: remove EDDP

Thanks,
        Frank
