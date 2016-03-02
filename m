From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-sysfs: remove left over dead code
Date: Wed, 02 Mar 2016 15:02:40 -0500 (EST)
Message-ID: <20160302.150240.520466023164750512.davem@davemloft.net>
References: <1456763665-499-1-git-send-email-eric.engestrom@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@mellanox.com, ogerlitz@mellanox.com,
	gospo@cumulusnetworks.com, dsahern@gmail.com,
	alexander.stein@systec-electronic.com, cascardo@redhat.com,
	john.r.fastabend@intel.com, f.fainelli@gmail.com,
	anuradhak@cumulusnetworks.com, rmk+kernel@arm.linux.org.uk,
	tom@herbertland.com, sasha.levin@oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.engestrom@imgtec.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456763665-499-1-git-send-email-eric.engestrom@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Engestrom <eric.engestrom@imgtec.com>
Date: Mon, 29 Feb 2016 16:34:25 +0000

> This format hasn't been used since 04ed3e741d0f133e02bed7fa5c98edba128f90e7
> ("net: change netdev->features to u32")
> 
> Signed-off-by: Eric Engestrom <eric.engestrom@imgtec.com>

A patch that does this is already in the networking tree, please always
check the appropriate subsystem tree before submitting patches.

Thanks.
