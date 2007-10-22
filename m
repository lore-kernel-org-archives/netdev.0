From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [RFC][PATCH 0/3][XFRM]: Support packet processing error statistics.
Date: Mon, 22 Oct 2007 15:11:06 +0900
Message-ID: <11930334662094-git-send-email-nakam@linux-ipv6.org>
References: <20071017.213523.58458049.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:47264 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751525AbXJVGcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 02:32:17 -0400
In-Reply-To: <20071017.213523.58458049.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces statistics about transformation error (or almost error)
factor at packet processing for developer.
It is not a SNMP/MIB specification from IPsec/MIPv6 but a counter
designed from current transformation source code.

Comment please.
