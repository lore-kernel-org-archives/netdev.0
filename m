From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Patch to fix scheduling while atomic splat
Date: Tue, 25 Nov 2014 10:45:40 -0600
Message-ID: <5474B234.9090701@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org >> netdev" <netdev@vger.kernel.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:41438 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752369AbaKYQpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:45:41 -0500
Received: by mail-oi0-f54.google.com with SMTP id u20so673510oif.27
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 08:45:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg,

On Nov. 12, I sent a patch for kernel 3.18 with the subject "[PATCH for 3.18] 
staging: r8188eu: Fix scheduling while atomic error introduced in commit 
fadbe0cd". To date, this fix does not seem to have appeared in mainline. Did it 
get missed?

Thanks,

Larry
