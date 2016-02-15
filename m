From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] ravb: Update DT binding example for final CPG/MSSR
 bindings
Date: Tue, 16 Feb 2016 08:43:07 +0900
Message-ID: <20160215234307.GC22351@verge.net.au>
References: <1455540091-23427-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	linux-renesas-soc@vger.kernel.org, netdev@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1455540091-23427-1-git-send-email-geert+renesas@glider.be>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 15, 2016 at 01:41:31PM +0100, Geert Uytterhoeven wrote:
> The example in the DT binding documentation uses the preliminary DT
> bindings for the r8a7795 MSTP clocks, which never went upstream.
> Update the example to use the DT bindings for the upstream Clock Pulse
> Generator / Module Standby and Software Reset hardware block.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Reviewed-by: Simon Horman <horms+renesas@verge.net.au>
