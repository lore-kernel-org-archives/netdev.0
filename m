From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH for-next V1 0/2] mlx5_core: mlx5_ifc updates
Date: Fri, 15 Apr 2016 20:10:07 +0300
Message-ID: <CALzJLG__o56edSf__To-BM6jakuwP7zAAEEQH8LQNTKp-2LRDQ@mail.gmail.com>
References: <1460563864-22931-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Doug Ledford <dledford@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-rdma@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:34496 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbcDORK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 13:10:28 -0400
Received: by mail-yw0-f195.google.com with SMTP id h6so15644494ywc.1
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 10:10:27 -0700 (PDT)
In-Reply-To: <1460563864-22931-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 13, 2016 at 7:11 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
> Hi Dave and Doug
>
> Changes form V0:
>         - 2nd patch commit message fixes.
>
> This series include mlx5_core updates for both net-next and rdma
> trees for 4.7 kernel cycle. This is the only shared code planned
> for 4.7 between rdma and net trees. Hopefully, this will prevent
> future conflicts when merging between ib-next and net-next once
> 4.7 cycle is over and merge window is opened.
>
> Both Mellanox rdma and net submissions will proceed once this series
> is applied into both trees.
>
> Future shared code will be sent to both maintainers as pull requests
> from Mellanox's kernel.org tree.
>
> We have included all the maintainers of respective drivers.
> Kindly review the change and let us know in case of any review comments.
>
> Saeed Mahameed (1):
>   net/mlx5: Update mlx5_ifc hardware features
>
> Tariq Toukan (1):
>   net/mlx5: Fix mlx5 ifc cmd_hca_cap bad offsets
>
>  include/linux/mlx5/mlx5_ifc.h |  253 +++++++++++++++++++++++++++++------------
>  1 files changed, 179 insertions(+), 74 deletions(-)
>
> --

Hi Dave,

This series is still in "Changes Requested" state in patchwork, but
there is nothing to change here.
I will be glad if you give it a shot, it is blocking all of our mlx5
activities for both net and rdma trees.

Thanks,
Saeed.
