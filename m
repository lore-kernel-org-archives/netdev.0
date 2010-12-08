From: frank.blaschka@de.ibm.com
Subject: [patch 0/4] s390: qeth patches for net-next
Date: Wed, 08 Dec 2010 13:57:57 +0100
Message-ID: <20101208125757.726629855@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:58352 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544Ab0LHM6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 07:58:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here is another patch set for net-next.

shortlog:
Jan Glauber (1)
qeth: buffer count imbalance

Einar Lueck (2)
qeth: support ipv6 query arp cache for HiperSockets
qeth: support VIPA add/del in offline mode

Frank Blaschka (1)
qeth: l3 add vlan hdr in passthru frames

Thanks,
        Frank
