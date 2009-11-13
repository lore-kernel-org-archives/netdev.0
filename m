From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 PATCH v6 0/7 RFC] TCPCT part 1: cookie option exchange
Date: Thu, 12 Nov 2009 23:03:42 -0500
Message-ID: <4AFCDA9E.8050003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:47430 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755487AbZKMEDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 23:03:39 -0500
Received: by yxe17 with SMTP id 17so2616186yxe.33
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 20:03:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although 'make vmlinux' compiles this successfully, it is not tested.
Keep in mind that earlier variants were extensively tested.  But at least
this helps move the review comment process along....

Updated and reorganized to split the code base into several pieces, as
requested by Eric.  No significant changes.

The new TCP_MSS_* symbols are now in an entirely separate patch.
