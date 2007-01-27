From: Baruch Even <baruch@ev-en.org>
Subject: [PATCH 0/3] Fix issues with SACK processing
Date: Sat, 27 Jan 2007 18:47:02 +0200
Message-ID: <20070127164702.GA4829@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:54564
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751917AbXA0QrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jan 2007 11:47:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches are intended to fix the issues I've raised in a former
email in addition to the sorting code.

I still was not able to runtime test these patches, they were only
compile tested.

Baruch
