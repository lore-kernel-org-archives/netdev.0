From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [RFC PATCH 0/8] Implement SCTP-AUTH specification.
Date: Fri, 14 Sep 2007 14:44:51 -0400
Message-ID: <1189795499444-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org
To: lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:55126 "EHLO atlrel7.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754218AbXINSpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 14:45:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All

The following series of 8 patches is the implementation of SCTP-AUTH
spec (RFC 4895) that was tested at the 9th SCTP Interop.  The code is
based on the implementation of the Supported Extensions parameter that
was send out separately for inclusion into 2.6.24.

I'd really appreciate people reviewing this as I hope for this
to make the 2.6.24 code base.

Thanks
-vlad
