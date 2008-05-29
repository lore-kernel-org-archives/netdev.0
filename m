From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/3] virtio_net: Trivial coding style fix
Date: Thu, 29 May 2008 16:43:18 +1000
Message-ID: <200805291643.18533.rusty@rustcorp.com.au>
References: <1211887247-31979-1-git-send-email-markmc@redhat.com>
	<1211887247-31979-2-git-send-email-markmc@redhat.com>
	<1211887247-31979-3-git-send-email-markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1211887247-31979-3-git-send-email-markmc@redhat.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tuesday 27 May 2008 21:20:46 Mark McLoughlin wrote:
> -		if (!skb_partial_csum_set(skb,hdr->csum_start,hdr->csum_offset))
> +		if (!skb_partial_csum_set(skb, hdr->csum_start, hdr->csum_offset))

I compressed the whitespace to avoid going over 80 cols.  A choice of lesser 
evils :)

Cheers,
Rusty.
