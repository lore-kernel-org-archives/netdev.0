From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH v2 1/1] xen-netfront: update num_queues to real created
Date: Mon, 19 Oct 2015 09:47:12 -0400
Message-ID: <5624F460.90108@oracle.com>
References: <5624818D.4010902@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	stable@vger.kernel.org
To: Joe Jin <joe.jin@oracle.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	ian.campbell@citrix.com, wei.liu2@citrix.com,
	"annie.li@oracle.com" <annie.li@oracle.com>, davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <5624818D.4010902@oracle.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/19/2015 01:37 AM, Joe Jin wrote:
> Sometimes xennet_create_queues() may failed to created all requested
> queues, we need to update num_queues to real created to avoid NULL
> pointer dereference.
>
> Signed-off-by: Joe Jin <joe.jin@oracle.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David S. Miller <davem@davemloft.net>


Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
