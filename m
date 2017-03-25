From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Subject: Re: [PATCH net] ping: implement proper locking
Date: Sat, 25 Mar 2017 01:44:55 +0100
Message-ID: <ebb73246-5585-3390-6898-efd584fa140f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <edumazet@google.com>,
        Solar Designer <solar@openwall.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34892 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751451AbdCYAo6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 20:44:58 -0400
Received: by mail-wr0-f195.google.com with SMTP id u108so750408wrb.2
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 17:44:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Solar Designer wrote:

> We should credit the original reporter, who most likely found this by
> fuzzing.  It's danieljiang0415 on GitHub and Twitter.  Unfortunately, I
> don't know their e-mail address.  I'll try asking.

Daniel Jiang <danieljiang0415@gmail.com>
