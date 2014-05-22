From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: question: Any way to trigger DHCP renewal from kernel code?
Date: Thu, 22 May 2014 22:24:24 +0000
Message-ID: <c64a7b76572942fda9acffc25dd76c29@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na01-sn2-obe.ptr.o365filtering.com ([157.55.158.29]:45718 "EHLO
	na01-sn2-obe.outbound.o365filtering.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752663AbaEVWYb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2014 18:24:31 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Our synthetic network driver is notified when the Hyper-V host 
resume from sleep/hibernation. We need to renew DHCP in this case.
I'm looking for a way to trigger DHCP renewal from kernel mode 
code.

Can anyone help me?

Thanks,
- Haiyang
