From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 0/3] bnx2x: Enhancement patch series
Date: Thu, 26 Jun 2014 14:31:03 +0300
Message-ID: <1403782266-25362-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:47259 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756998AbaFZLbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 07:31:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series introduces the ability to propagate link parameters
to VFs as well as control the VF link via hypervisor.

In addition, it contains 2 small improvements [one IOV-related and the
other improves performance on machines with short cache lines].

Please consider applying these patches to `net-next'.

Thanks,
Yuval Mintz
