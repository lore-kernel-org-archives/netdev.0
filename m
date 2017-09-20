From: Stephen Hemminger <stephen@networkplumber.org>
Subject: RFC iproute2 doc files
Date: Wed, 20 Sep 2017 08:11:59 -0700
Message-ID: <20170920081159.321e426b@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:44279 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751507AbdITPME (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 11:12:04 -0400
Received: by mail-pf0-f174.google.com with SMTP id e1so1679417pfk.1
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 08:12:04 -0700 (PDT)
Received: from xeon-e3 (76-14-207-240.or.wavecable.com. [76.14.207.240])
        by smtp.gmail.com with ESMTPSA id v24sm9198396pfi.132.2017.09.20.08.12.03
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Sep 2017 08:12:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed that the iproute man pages are up to date but the LaTex documentation
is very out of date. Rarely updated since the Linux 2.2 days.

Either someone needs to do a massive editing job on them, or they should just
be dropped. My preference would be to just drop everything in the doc/ directory.
The current versions are so old, they can't be helping.
