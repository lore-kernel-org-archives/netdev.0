From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 0/3]qlcnic: bug fixes
Date: Tue, 26 Oct 2010 20:53:06 -0700
Message-ID: <1288151589-32431-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:64531 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752301Ab0J0DxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Oct 2010 23:53:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
  Series v2 of 3 patches for bug fixes. Patches are numbered.
  Dropping "dma address align check" patch as pci_alloc_consistent is gaurantee to give
  page align dma address.

-Amit 
