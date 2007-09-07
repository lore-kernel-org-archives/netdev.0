From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 02/18] sundance: PHY address form 0, only for device I
  D 0x0200 (IP100A) (20070605)
Date: Fri, 07 Sep 2007 19:23:30 -0400
Message-ID: <46E1DD72.1080608@garzik.org>
References: <AA68EB0EBA29BA40A06B700C33343EEF018686DF@fileserver.icplus.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: =?UTF-8?B?6buD5bu66IiILUplc3Nl?= <Jesse@icplus.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35082 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130AbXIGXXh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 19:23:37 -0400
In-Reply-To: <AA68EB0EBA29BA40A06B700C33343EEF018686DF@fileserver.icplus.com.tw>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just so I understand you correctly,

	1) IP100A support requires modified sundance.c

	2) IP1000A support requires new driver

Is this correct?

If so, please resend the IP1000A driver, I don't have it in my email.

	Jeff



