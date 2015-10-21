From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] xen-netfront: update num_queues to real created
Date: Wed, 21 Oct 2015 07:45:52 -0700 (PDT)
Message-ID: <20151021.074552.2288341578443947313.davem@davemloft.net>
References: <5624818D.4010902@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: boris.ostrovsky@oracle.com, konrad.wilk@oracle.com,
	ian.campbell@citrix.com, wei.liu2@citrix.com, annie.li@oracle.com,
	netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	stable@vger.kernel.org
To: joe.jin@oracle.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <5624818D.4010902@oracle.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Jin <joe.jin@oracle.com>
Date: Mon, 19 Oct 2015 13:37:17 +0800

> Sometimes xennet_create_queues() may failed to created all requested
> queues, we need to update num_queues to real created to avoid NULL
> pointer dereference.
> 
> Signed-off-by: Joe Jin <joe.jin@oracle.com>

Applied.
