From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 6/7] net/mlx5: E-Switch, Add control for inline
 mode
Date: Sun, 8 Jan 2017 10:56:30 +0100
Message-ID: <20170108095630.GA1971@nanopsycho>
References: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
 <1479733561-26601-7-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36084 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937208AbdAHJ4f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 04:56:35 -0500
Received: by mail-wm0-f68.google.com with SMTP id m203so14904546wma.3
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 01:56:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1479733561-26601-7-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Nov 21, 2016 at 02:06:00PM CET, saeedm@mellanox.com wrote:
>From: Roi Dayan <roid@mellanox.com>
>
>Implement devlink show and set of HW inline-mode.
>The supported modes: none, link, network, transport.
>We currently support one mode for all vports so set is done on all vports.
>When eswitch is first initialized the inline-mode is queried from the FW.
>
>Signed-off-by: Roi Dayan <roid@mellanox.com>
>Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

Saeed, could you please use get_maintainer script and cc those people
for you submissions? Thanks!
