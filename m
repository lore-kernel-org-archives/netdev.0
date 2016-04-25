From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2] sh_eth: rename ARSTR register bit
Date: Mon, 25 Apr 2016 10:37:42 +1000
Message-ID: <20160425003742.GE30009@verge.net.au>
References: <16246598.T4zYgEztZA@wasted.cogentembedded.com>
 <11425579.ULGl4KSfTY@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <11425579.ULGl4KSfTY@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 24, 2016 at 11:46:15PM +0300, Sergei Shtylyov wrote:
> The Renesas RZ/A1H manual names the software reset bit in the software reset
> register (ARSTR) ARST which makes a bit more sense than the ARSTR_ARSTR name
> used now  by the driver -- rename the latter to ARSTR_ARST.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Reviewed-by: Simon Horman <horms+renesas@verge.net.au>
