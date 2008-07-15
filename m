From: "Adam Langley" <agl@imperialviolet.org>
Subject: [Resend PATCH 0/3] TCP: fixing TCP MD5
Date: Tue, 15 Jul 2008 09:30:40 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe069010@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:18155 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835AbYGOQbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 12:31:18 -0400
Received: by wa-out-1112.google.com with SMTP id j37so3084045waf.23
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 09:31:17 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series applies against net-next-2.6 and I've been running it for a while.
It's technically a resend, but these patches have been split up across a number
of threads previously.
