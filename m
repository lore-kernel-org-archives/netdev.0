From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] net: thunderx: Support for pass-2 hw features
Date: Fri, 11 Dec 2015 23:38:32 -0500 (EST)
Message-ID: <20151211.233832.338534313937495741.davem@davemloft.net>
References: <y>
	<1449734120-8912-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, p.fedin@samsung.com,
	Sunil.Goutham@caviumnetworks.com, sgoutham@cavium.com
To: sunil.kovvuri@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449734120-8912-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sunil.kovvuri@gmail.com>
Date: Thu, 10 Dec 2015 13:25:18 +0530

> From: Sunil Goutham <sgoutham@cavium.com>
> 
> This patch set adds support for new features added in pass-2 revision
> of hardware like TSO and count based interrupt coalescing.
> 
> Changes from v1:
> - Addressed comments received regarding boolean bit field changes 
>   by excluding them from this patch. Will submit a seperate
>   patch along with cleanup of unsed field.
> - Got rid of new macro 'VNIC_NAPI_WEIGHT' introduced in 
>   count threshold interrupt patch.

Series applied to net-next, thanks.
