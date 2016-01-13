From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch] mlxsw: fix SWITCHDEV_OBJ_ID_PORT_MDB
Date: Wed, 13 Jan 2016 14:38:11 +0100
Message-ID: <20160113133811.GA2218@nanopsycho.orion>
References: <20160113122823.GD19993@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Elad Raz <eladr@mellanox.com>,
	Ido Schimmel <idosch@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160113122823.GD19993@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Jan 13, 2016 at 01:28:23PM CET, dan.carpenter@oracle.com wrote:
>There is a missing break statement so we always return -EOPNOTSUPP.
>
>Fixes: 3a49b4fde2a1 ('mlxsw: Adding layer 2 multicast support')
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
