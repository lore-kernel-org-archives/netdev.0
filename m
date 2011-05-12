From: frank.blaschka@de.ibm.com
Subject: [patch 0/9] [resend] s390: network feature patches for net-next
Date: Thu, 12 May 2011 07:43:18 +0200
Message-ID: <20110512054318.241733700@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:40300 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385Ab1ELFoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 01:44:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I have updated the hw_features patch with feedback from Michal
and respined the patch set.

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

