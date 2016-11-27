From: Roi Dayan <roid@mellanox.com>
Subject: Re: [PATCH iproute2 0/2] Adding help and inline mode control to
 eswitch
Date: Sun, 27 Nov 2016 13:30:21 +0200
Message-ID: <583AC3CD.20904@mellanox.com>
References: <1480245663-814-1-git-send-email-roid@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <roid@mellanox.com>, <netdev@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0056.outbound.protection.outlook.com ([104.47.2.56]:29424
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751425AbcK0PFj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Nov 2016 10:05:39 -0500
In-Reply-To: <1480245663-814-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

I forgot to mention that the patches are for net-next branch of iproute2.

Thanks,
Roi


On 27/11/2016 13:21, Roi Dayan wrote:
> Hi,
>
> The first patch is adding missing help message for eswitch.
> The second patch is adding functionality to show/modify eswitch inline mode.
>
> Thanks,
> Roi
>
>
> Roi Dayan (2):
>    devlink: Add usage help for eswitch subcommand
>    devlink: Add option to set and show eswitch inline mode
>
>   devlink/devlink.c       |   89 +++++++++++++++++++++++++++++++++++++++++++++-
>   include/linux/devlink.h |    8 ++++
>   man/man8/devlink-dev.8  |   21 ++++++++++-
>   3 files changed, 115 insertions(+), 3 deletions(-)
>
