From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch v2 1/2] Allow Mellanox switch devices to be configured if
 only I2C bus is set
Date: Mon, 14 Aug 2017 15:55:29 +0200
Message-ID: <20170814135529.GA10446@nanopsycho>
References: <1502725102-182550-1-git-send-email-ohado@mellanox.com>
 <1502725102-182550-2-git-send-email-ohado@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, saeedm@mellanox.com,
        vadimp@mellanox.com, system-sw-low-level@mellanox.com
To: Ohad Oz <ohado@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33365 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752368AbdHNNzc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 09:55:32 -0400
Received: by mail-wm0-f68.google.com with SMTP id q189so14613366wmd.0
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 06:55:31 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1502725102-182550-2-git-send-email-ohado@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Aug 14, 2017 at 05:38:21PM CEST, ohado@mellanox.com wrote:
>Mellanox switches (mlxsw) supports I2C systems without PCI, in order to
>give the ability to the users to use such functionality, there is need
>to update Kconfig.
>
>Signed-off-by: Ohad Oz <ohado@mellanox.com>
>Acked-by: Leon Romanovsky <leonro@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
