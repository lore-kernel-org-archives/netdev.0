From: Oliver Neukum <oneukum@suse.com>
Subject: question on devices that have a UUID but no MAC
Date: Sun, 14 May 2017 18:48:27 +0200
Message-ID: <1494780507.21837.6.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33157 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1759061AbdENQu4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 14 May 2017 12:50:56 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 8D039AAB4
        for <netdev@vger.kernel.org>; Sun, 14 May 2017 16:50:55 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

is there a canonical way to use a device's UUID to generate a MAC
inside the kernel? If I add it, where does it belong into?

	Regards
		Oliver
