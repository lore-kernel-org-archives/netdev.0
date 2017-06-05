From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v2] devlink: fix potential memort leak
Date: Mon, 5 Jun 2017 06:51:16 +0200
Message-ID: <20170605045116.GB1929@nanopsycho.orion>
References: <1496624241-25794-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Arkadi Sharshevsky <arkadis@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1496624241-25794-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Jun 05, 2017 at 02:57:21AM CEST, yanhaishuang@cmss.chinamobile.com wrote:
>We must free allocated skb when genlmsg_put() return fails.
>
>Fixes: 1555d204e743 ("devlink: Support for pipeline debug (dpipe)")
>Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>

Thanks.
