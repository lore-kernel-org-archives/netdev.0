From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: query: net-next section mismatch(es)
Date: Sun, 08 Nov 2009 09:13:09 -0500
Message-ID: <4AF6D1F5.80307@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:34836 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753141AbZKHONG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2009 09:13:06 -0500
Received: by ywh40 with SMTP id 40so1972660ywh.33
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2009 06:13:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yesterday morning (and for a month), I was getting the usual:

   WARNING: modpost: Found 1 section mismatch(es).
   To see full details build your kernel with:
   'make CONFIG_DEBUG_SECTION_MISMATCH=y'

This morning, it changed:

   WARNING: modpost: Found 4 section mismatch(es).
   To see full details build your kernel with:
   'make CONFIG_DEBUG_SECTION_MISMATCH=y'

I remember compiling it once with that option, and not finding anything
wrong in my code, but I'm wondering how it took a great leap?
