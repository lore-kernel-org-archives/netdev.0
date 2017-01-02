From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH for-next V2 00/11] Mellanox mlx5 core and ODP updates 2017-01-01
Date: Tue, 3 Jan 2017 01:30:16 +0200
Message-ID: <CALzJLG9ZBRMOVqFsTypCLV6Rrek8a9g43z0spvVKeku6WdWCTA@mail.gmail.com>
References: <1483349868-11716-1-git-send-email-saeedm@mellanox.com> <20170102.155341.1496970446718890403.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Doug Ledford <dledford@redhat.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        ilyal@mellanox.com, artemyko@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:35859 "EHLO
        mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756808AbdABXaj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 18:30:39 -0500
Received: by mail-lf0-f44.google.com with SMTP id t196so276959174lff.3
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 15:30:38 -0800 (PST)
In-Reply-To: <20170102.155341.1496970446718890403.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 2, 2017 at 10:53 PM, David Miller <davem@davemloft.net> wrote:
> From: Saeed Mahameed <saeedm@mellanox.com>
> Date: Mon,  2 Jan 2017 11:37:37 +0200
>
>> The following eleven patches mainly come from Artemy Kovalyov
>> who expanded mlx5 on-demand-paging (ODP) support. In addition
>> there are three cleanup patches which don't change any functionality,
>> but are needed to align codebase prior accepting other patches.
>
> Series applied to net-next, thanks.

Whoops,

This series was meant as a pull request, you can blame it on me I
kinda messed up the V2 title.
Doug will have to pull same patches later, will this produce a
conflict on merge window ?

Sorry for the confusion.
