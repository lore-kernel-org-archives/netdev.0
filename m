From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] team: fall back to hash if table entry is
 empty
Date: Tue, 19 Sep 2017 16:19:18 -0700 (PDT)
Message-ID: <20170919.161918.690471491257223653.davem@davemloft.net>
References: <1505846019-6785-1-git-send-email-hanko@drivescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: hanko@drivescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505846019-6785-1-git-send-email-hanko@drivescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jim Hanko <hanko@drivescale.com>
Date: Tue, 19 Sep 2017 11:33:39 -0700

> If the hash to port mapping table does not have a valid port (i.e. when
> a port goes down), fall back to the simple hashing mechanism to avoid
> dropping packets.
> 
> Signed-off-by: Jim Hanko <hanko@drivescale.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks.
