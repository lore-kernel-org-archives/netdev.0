From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/5] skge: use netdev_alloc_skb
Date: Wed, 06 Sep 2006 11:19:54 -0400
Message-ID: <44FEE71A.8060908@pobox.com>
References: <20060901225346.750571061@zqx3.pdx.osdl.net> <20060901225449.031404541@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:22491 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751401AbWIFPTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 11:19:55 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060901225449.031404541@zqx3.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

applied patches 1-4.  patch #5 does not apply:

[jgarzik@pretzel netdev-2.6]$ git-applymbox /g/tmp/mbox ~/info/signoff.txt
5 patch(es) to process.

Applying 'skge: use netdev_alloc_skb'

Wrote tree 5933a42766864a3117611ec1c999758e9f8a2f38
Committed: c54f9765daafe8493dba837b3d70e97432cd876a

Applying 'skge: irq lock race'

Wrote tree d896de1c7306f0f03c9781cb054bbcd5cf0a9817
Committed: 29365c900963d4986b74a0dadea46872bf283d76

Applying 'skge: use NAPI for transmit complete'

Wrote tree 84d8d7355f8c14f3abd57e8e313ce39ed09e3d05
Committed: 513f533e3f161c5a59555677d35e8ae28037bd89

Applying 'skge: version 1.8'

Wrote tree f17e223a4b80c22e82c2a8543806aebad4e6e77c
Committed: f6aa1693671fa9ea661fd30f003820d129fe0628

Applying 'skge: pci_post bugs'

error: patch failed: drivers/net/skge.c:2747
error: drivers/net/skge.c: patch does not apply


