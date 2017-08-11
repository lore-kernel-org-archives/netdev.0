From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] mlxsw: make mlxsw_config_profile const
Date: Fri, 11 Aug 2017 17:32:00 +0200
Message-ID: <20170811153200.GE1852@nanopsycho>
References: <1502458842-31516-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr, jiri@mellanox.com, idosch@mellanox.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Bhumika Goyal <bhumirks@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1502458842-31516-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, Aug 11, 2017 at 03:40:42PM CEST, bhumirks@gmail.com wrote:
>Make these structures const as they only stored in the profile field of
>a mlxsw_driver structure, which is of type const.
>Done using Coccinelle.
>
>Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
