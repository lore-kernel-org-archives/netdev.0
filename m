From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 4/7] devlink: Add E-Switch inline mode control
Date: Sun, 8 Jan 2017 11:29:02 +0100
Message-ID: <20170108102902.GB1971@nanopsycho>
References: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
 <1479733561-26601-5-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:32946 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754352AbdAHK3F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 05:29:05 -0500
Received: by mail-wj0-f194.google.com with SMTP id kp2so82588994wjc.0
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 02:29:05 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1479733561-26601-5-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 21, 2016 at 02:05:58PM CET, saeedm@mellanox.com wrote:
>From: Roi Dayan <roid@mellanox.com>
>
>Some HWs need the VF driver to put part of the packet headers on the
>TX descriptor so the e-switch can do proper matching and steering.

Could you please elaborate a bit about possible use-cases for different
modes? Thanks.


>
>The supported modes: none, link, network, transport.
>
>Signed-off-by: Roi Dayan <roid@mellanox.com>
>Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
