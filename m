From: Dawid Ciezarkiewicz <dawid.ciezarkiewicz@gmail.com>
Subject: [RFC] wrr (weighted round-robin) bonding
Date: Mon, 16 Oct 2006 20:21:12 +0200
Message-ID: <200610162021.12884.dpc@asn.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:19758 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S1422778AbWJPSVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 14:21:20 -0400
Received: by ug-out-1314.google.com with SMTP id o38so822563ugd
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2006 11:21:18 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch is little thinner then the previous one.

