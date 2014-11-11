From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [PATCH V1 net-next] net/fm10k: Avoid double setting of
 NETIF_F_SG for the HW encapsulation feature mask
Date: Tue, 11 Nov 2014 16:37:22 +0000
Message-ID: <D0877B1E.5F2FF%matthew.vick@intel.com>
References: <1415520822-11922-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:63234 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999AbaKKQib convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 11:38:31 -0500
In-Reply-To: <1415520822-11922-1-git-send-email-ogerlitz@mellanox.com>
Content-Language: en-US
Content-ID: <9F7CEF5202DC964EB9B913DE79CD6508@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/9/14, 12:13 AM, "Or Gerlitz" <ogerlitz@mellanox.com> wrote:

>The networking core does it for the driver during registration time.
>
>Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
>---
>
>changes from v0:
> - set alignment to be per the request of Matthew Vick

Thanks Or! I'll add my ACK as this passes through Jeff's queue.
