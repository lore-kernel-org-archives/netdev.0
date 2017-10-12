From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 0/3] Adding config get/set to devlink
Date: Thu, 12 Oct 2017 12:01:56 -0700 (PDT)
Message-ID: <20171012.120156.1222864362390761311.davem@davemloft.net>
References: <20171012144032.GG14672@nanopsycho>
        <CAJieiUiFmBr72yYP9VNtm0VBTNjJcA6Lj5nHJNBjDBC4moxE2A@mail.gmail.com>
        <20171012150419.GI14672@nanopsycho>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, steven.lin1@broadcom.com,
        netdev@vger.kernel.org, jiri@mellanox.com,
        michael.chan@broadcom.com, linux-pci@vger.kernel.org,
        linville@tuxdriver.com, gospo@broadcom.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55128 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751348AbdJLTB5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 15:01:57 -0400
In-Reply-To: <20171012150419.GI14672@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 12 Oct 2017 17:04:19 +0200

> Not sure we want to go this way and add "netdev"-handle things into
> devlink. Thoughts?

I think we should avoid this and keep devlink to it's designed purpose.
