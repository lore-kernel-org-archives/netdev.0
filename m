From: Kamal Mostafa <kamal@canonical.com>
Subject: Re: [PATCH][v4.2.y-ckt] net/mlx5e: Max mtu comparison fix
Date: Tue, 05 Jan 2016 13:13:46 -0800
Message-ID: <1452028426.7370.6.camel@fourier>
References: <568C2F10.9040707@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kamal Mostafa <kamal.mostafa@canonical.com>, doront@mellanox.com,
	saeedm@mellanox.com, ogerlitz@mellanox.com,
	"davem@davemloft.net" <davem@davemloft.net>, eli@mellanox.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-rdma@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: Joseph Salisbury <joseph.salisbury@canonical.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <568C2F10.9040707@canonical.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-01-05 at 16:01 -0500, Joseph Salisbury wrote:
> Hello,
> 
> Please consider including mainline commit
> 50a9eea694ab8e0779069e0a4e0b12e145521468 in the next v4.2.y-ckt
> release.  It was
> included in the mainline tree as of v4.4-rc2.  It has been tested and
> confirmed to resolve:
> http://bugs.launchpad.net/bugs/1528466


Yes, I'll queue this up for 4.2.8-ckt1.  Thanks, Joseph!

 -Kamal

> commit 50a9eea694ab8e0779069e0a4e0b12e145521468
> Author: Doron Tsur <doront@mellanox.com>
> Date:   Thu Nov 12 19:35:27 2015 +0200
> 
>     net/mlx5e: Max mtu comparison fix
> 
> 
> Sincerely,
> 
> Joseph Salisbury
> 
> 
