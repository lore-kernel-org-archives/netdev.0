From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH] drivers: net: xen-netfront: remove unused arrays
Date: Tue, 15 Apr 2014 18:54:12 +0100
Message-ID: <534D7244.5000002@citrix.com>
References: <1397583579-32162-1-git-send-email-v.maffione@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <konrad.wilk@oracle.com>, <boris.ostrovsky@oracle.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Vincenzo Maffione <v.maffione@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1397583579-32162-1-git-send-email-v.maffione@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15/04/14 18:39, Vincenzo Maffione wrote:
> This patch removes some unused arrays from the netfront
> private data structure.
> Also removes an unused address variable.
> 
> Signed-off-by: Vincenzo Maffione <v.maffione@gmail.com>

Huh. I wonder what they were for.

Acked-by: David Vrabel <david.vrabel@citrix.com>

For net related patches please say whether they're for the net (current
RCs) or net-next branch.  e.g.,

[PATCH net-next] xen-netfront: removed unused arrays.

Thanks.

David
