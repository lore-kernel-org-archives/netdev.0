From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [RFC net-next v2 00/71] Organize/Move of the Ethernet drivers in
 drivers/net/
Date: Sun, 31 Jul 2011 18:45:16 +0300
Message-ID: <20110731154515.GA3357@p183.telecom.by>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34020 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949Ab1GaPpS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2011 11:45:18 -0400
Received: by fxh19 with SMTP id 19so3767811fxh.19
        for <netdev@vger.kernel.org>; Sun, 31 Jul 2011 08:45:17 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> drivers/net/{ => ethernet/3com}/3c501.c

I for one appreciate that Linux has short overall directory
structure. At work we have like 5-6 directories before
actual code and it sucks very much.

> have tab-completion actually work

What do you mean?
