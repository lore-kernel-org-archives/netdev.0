From: frank.blaschka@de.ibm.com
Subject: [patch 0/5] s390: qeth patches for 2.6.33
Date: Thu, 12 Nov 2009 11:11:40 +0100
Message-ID: <20091112101140.882313000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.17.167]:37027 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380AbZKLKM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 05:12:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here is a set of qeth patches for 2.6.33 (net-next).

shortlog:
Einar Lueck (1)
qeth: Exploit Connection Isolation

Ursula Braun (2)
qeth: remaining EDDP cleanup
qeth: Recognize return codes of ccw_device_set_online

Frank Blaschka (2)
qeth: rework TSO functions
qeth: allow dynamic change of rx checksumming

Thanks,
        Frank

