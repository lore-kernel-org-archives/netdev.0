From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 6/7] net/mlx5: E-Switch, Add control for inline mode
Date: Sun, 8 Jan 2017 17:58:17 +0200
Message-ID: <CALzJLG-RZ8denNt6k9YTc-org4ufz7ZBv3jPdmyAtT_ph-BtBg@mail.gmail.com>
References: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
 <1479733561-26601-7-git-send-email-saeedm@mellanox.com> <20170108095630.GA1971@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:34340 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752431AbdAHP6i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 10:58:38 -0500
Received: by mail-qk0-f182.google.com with SMTP id a20so120400036qkc.1
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2017 07:58:38 -0800 (PST)
In-Reply-To: <20170108095630.GA1971@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 8, 2017 at 11:56 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Mon, Nov 21, 2016 at 02:06:00PM CET, saeedm@mellanox.com wrote:
>>From: Roi Dayan <roid@mellanox.com>
>>
>>Implement devlink show and set of HW inline-mode.
>>The supported modes: none, link, network, transport.
>>We currently support one mode for all vports so set is done on all vports.
>>When eswitch is first initialized the inline-mode is queried from the FW.
>>
>>Signed-off-by: Roi Dayan <roid@mellanox.com>
>>Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
>
> Saeed, could you please use get_maintainer script and cc those people
> for you submissions? Thanks!

Sure,

Or, Roi, please make sure you do this in your future work.
I will verify prior to submission of course.
