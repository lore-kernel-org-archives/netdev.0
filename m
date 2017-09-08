From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] team: fall back to hash if table entry is empty
Date: Fri, 8 Sep 2017 07:55:59 +0200
Message-ID: <20170908055559.GA1895@nanopsycho>
References: <1504837512-16395-1-git-send-email-hanko@drivescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jim Hanko <hanko@drivescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:43379 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751599AbdIHF4C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 01:56:02 -0400
Received: by mail-wm0-f49.google.com with SMTP id f145so3452450wme.0
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 22:56:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1504837512-16395-1-git-send-email-hanko@drivescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 08, 2017 at 04:25:12AM CEST, hanko@drivescale.com wrote:
>If the hash to port mapping table does not have a valid port (i.e. when
>a port goes down), fall back to the simple hashing mechanism to avoid
>dropping packets.
>
>Signed-off-by: Jim Hanko <hanko@drivescale.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>

net-next is closed for now (will open after rc1 is out). Please re-send
the patch (including my ack) then.

Thanks.
