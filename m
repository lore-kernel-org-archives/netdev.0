From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net/mlx4_core: clean up two functions
Date: Mon, 13 Jan 2014 11:13:12 -0800 (PST)
Message-ID: <20140113.111312.1323236808342705421.davem@davemloft.net>
References: <1389099622.15032.18.camel@x41>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, jackm@dev.mellanox.co.il,
	ronye@mellanox.com, hadarh@mellanox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: pebolle@tiscali.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389099622.15032.18.camel@x41>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Bolle <pebolle@tiscali.nl>
Date: Tue, 07 Jan 2014 14:00:22 +0100

> 0) These two patches are very similar. They both clean up a function to
> help GCC understand the codeflow. Both help silence a warning.
> 
> 1) Compile tested only (on 32 bits x86). I do not have this hardware.
> 
> 2) Please note that there's no MAINTAINERS entry for mlx4_core. (Neither
> is there an entry for the MLX4 IB driver.) Shouldn't it be added? 

These patches have been rotting for a week.  I know the mlx4 folks
said the SRIOV guy inside Mellanox will look at it, but this is taking
way too long.

This is absolutely unreasonable from Paul's perspective to have to wait
this long for a review of these relatively simple patches.
