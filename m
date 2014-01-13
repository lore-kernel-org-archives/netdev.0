From: Amir Vadai <amirv@mellanox.com>
Subject: Re: net/mlx4_core: clean up two functions
Date: Mon, 13 Jan 2014 21:34:17 +0200
Message-ID: <20140113193415.GA22955@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <1389099622.15032.18.camel@x41>
 <20140113.111312.1323236808342705421.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pebolle@tiscali.nl, ogerlitz@mellanox.com,
	jackm@dev.mellanox.co.il, ronye@mellanox.com, hadarh@mellanox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	amirv@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140113.111312.1323236808342705421.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/01/14 11:13 -0800, David Miller wrote:
> From: Paul Bolle <pebolle@tiscali.nl>
> Date: Tue, 07 Jan 2014 14:00:22 +0100
> 
> > 0) These two patches are very similar. They both clean up a function to
> > help GCC understand the codeflow. Both help silence a warning.
> > 
> > 1) Compile tested only (on 32 bits x86). I do not have this hardware.
> > 
> > 2) Please note that there's no MAINTAINERS entry for mlx4_core. (Neither
> > is there an entry for the MLX4 IB driver.) Shouldn't it be added? 
> 
> These patches have been rotting for a week.  I know the mlx4 folks
> said the SRIOV guy inside Mellanox will look at it, but this is taking
> way too long.
> 
> This is absolutely unreasonable from Paul's perspective to have to wait
> this long for a review of these relatively simple patches.

You're absolutely right.
And yes, jack is very busy.
We will have a reply ready tomorrow morning.

Amir


> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
