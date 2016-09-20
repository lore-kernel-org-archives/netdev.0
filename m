From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] mlxsw: spectrum: Make offloads stats functions
 static
Date: Tue, 20 Sep 2016 09:55:44 +0200
Message-ID: <20160920075544.GF1843@nanopsycho.orion>
References: <1474348448-13724-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>, netdev@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34033 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbcITHzs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 03:55:48 -0400
Received: by mail-wm0-f68.google.com with SMTP id l132so1911701wmf.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 00:55:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1474348448-13724-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Sep 20, 2016 at 07:14:08AM CEST, ogerlitz@mellanox.com wrote:
>The offloads stats functions are local to this file, make them static.
>
>Fixes: fc1bbb0f1831 ('mlxsw: spectrum: Implement offload stats ndo [..]')
>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
