From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] pmtu check conditions error in IPv6
Date: Wed, 26 May 2004 13:24:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040526132409.406c9d5b.davem@redhat.com>
References: <200403171130.30282.mashirle@us.ibm.com>
	<200405261319.55787.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <mashirle@us.ibm.com>
In-Reply-To: <200405261319.55787.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 26 May 2004 13:19:55 -0700
Shirley Ma <mashirle@us.ibm.com> wrote:

> Here is the patch. IPv6 pmtu check conditions were wrong in these two places.
> this patch is against 2.6.6 kernel. It has been tested under 2.6.5 kernel for 
> IPsec.

Patch applied, thanks Shirley.
