From: "Adam Langley" <agl@imperialviolet.org>
Subject: [Resend v2 PATCH 0/3] TCP: fixing TCP MD5
Date: Thu, 17 Jul 2008 16:08:10 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe069020@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:61622 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932958AbYGQXJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 19:09:43 -0400
Received: by yx-out-2324.google.com with SMTP id 8so36434yxm.1
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 16:09:42 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series applies against net-next-2.6 and I've been running it for a while.

The only changes this time round are the requested ones.
