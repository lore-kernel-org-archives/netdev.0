From: Amador Pahim <amador@pahim.org>
Subject: Find vlanid with non-root user
Date: Tue, 13 Aug 2013 17:46:45 -0300
Message-ID: <CAEFY+qzCQqEpLjjM1iBjtHmDh70ktpx+GCHgTuCceu1A53-1Tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:43265 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759160Ab3HMUrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 16:47:08 -0400
Received: by mail-lb0-f169.google.com with SMTP id u10so6242119lbi.14
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 13:47:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Is there a way to get vlanid from a vlan interface as a regular user?
Default permissions to /proc/net/vlan/ is 600.
-rw-------. 1 root root 0 Aug 13 17:23 /proc/net/vlan/eth1.10-fcoe

Not sure if deducting vlanid from vlan name is a reasonable way to do so.

Thank you in advance,.

Best Regards,
-- 
Pahim
