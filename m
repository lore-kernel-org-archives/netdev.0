From: Chu XJ <zhuxjc@gmail.com>
Subject: PROBLEM: a trivial bug in __copy_skb_header() ?
Date: Fri, 20 Feb 2009 16:45:33 +0800
Message-ID: <85a560bb0902200045t1412c662k9b8ec337020e154f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:64241 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709AbZBTIpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 03:45:34 -0500
Received: by wf-out-1314.google.com with SMTP id 28so1038570wfa.4
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2009 00:45:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all

     I'm just a newbie of Linux kernel from China. I just wonder
whether it should be "#ifdef CONFIG_XFRM" at the 504th line of
net/core/skbuff.c in the V2.6.28 source tree and previous version.

     PS: Sorry for not using the standard format, my question is too trivial.

Regards
Chu XJ
