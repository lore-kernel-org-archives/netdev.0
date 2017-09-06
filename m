From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: Re: ipset losing entries on its own
Date: Wed, 6 Sep 2017 16:01:15 +0530
Message-ID: <CAA5aLPiVsBLeew65P7_A_M1We8fBEWo5JC052oB5OxuYZtACXg@mail.gmail.com>
References: <CAA5aLPhEseXhOqSK=6K=5J2q-zn+8FpxhqOBV5NqCPNMAJqhow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:33411 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752600AbdIFKbQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 06:31:16 -0400
Received: by mail-pg0-f54.google.com with SMTP id t3so14630022pgt.0
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 03:31:16 -0700 (PDT)
In-Reply-To: <CAA5aLPhEseXhOqSK=6K=5J2q-zn+8FpxhqOBV5NqCPNMAJqhow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

output of ipset -L -t

Name: STORE
Type: hash:ip
Revision: 4
Header: family inet hashsize 1024 maxelem 65536
Size in memory: 50480
References: 1
