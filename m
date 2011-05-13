From: frank.blaschka@de.ibm.com
Subject: [patch 0/9] [resend v2] s390: network feature patches for net-next
Date: Fri, 13 May 2011 06:45:00 +0200
Message-ID: <20110513044500.190198403@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([194.196.100.165]:54822 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079Ab1EMEpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 00:45:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

after one more iteration the hw_feature patch is complete now.
I did some testing and could not find a problem so far. If
we find bugs during extensive regession testing I will provide
a bug fix so please apply this patch set now so it is available
for the next merge window. Thx!

shortlog:
Frank Blaschka (2)
qeth: convert to hw_features part 2
qeth: add OSA concurrent hardware trap

Sebastian Ott (1)
qeth: add owner to ccw driver

Heiko Carstens (2)
claw: remove unused return code handling
lcs: get rid of compile warning

Ursula Braun (3)
ctcm: get rid of compile warning
iucv: get rid of compile warning
af_iucv: get rid of compile warning

KOSAKI Motohiro (1)
convert old cpumask API into new one

Thanks,
        Frank

