From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] openvswitch: use vport instead of p
Date: Wed, 15 Oct 2014 23:26:01 -0400 (EDT)
Message-ID: <20141015.232601.1795517855303731790.davem@davemloft.net>
References: <1413399821-8558-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, pshelar@nicira.com,
	dev@openvswitch.org, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413399821-8558-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Wed, 15 Oct 2014 21:03:41 +0200

> All functions used struct vport *vport except
> ovs_vport_find_upcall_portid.
> 
> This fixes 1 kerneldoc warning
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
