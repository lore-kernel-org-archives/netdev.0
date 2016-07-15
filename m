From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/2] tracing: change owner name to driver name
 for devlink hwmsg tracepoint
Date: Thu, 14 Jul 2016 22:16:19 -0700 (PDT)
Message-ID: <20160714.221619.2079546102188512585.davem@davemloft.net>
References: <1468489049-6326-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arnd@arndb.de, rdunlap@infradead.org,
	linux-kernel@vger.kernel.org, idosch@mellanox.com,
	yotamg@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com, ivecera@redhat.com, rostedt@goodmis.org,
	mingo@redhat.com, jolsa@kernel.org
To: jiri@resnulli.us
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468489049-6326-1-git-send-email-jiri@resnulli.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 14 Jul 2016 11:37:28 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Turned on that driver->owner which is struct module is not available when
> modules are disabled. Better to depend on a driver name which is
> always available.
> 
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Fixes: e5224f0fe2 ("devlink: add hardware messages tracing facility")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
