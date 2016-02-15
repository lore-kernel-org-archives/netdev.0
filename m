From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/2] ravb: kill useless *switch* defaults
Date: Tue, 16 Feb 2016 08:37:22 +0900
Message-ID: <20160215233720.GA22351@verge.net.au>
References: <2504091.pf4fyK11eg@wasted.cogentembedded.com>
 <42828566.vpINptsK4T@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <42828566.vpINptsK4T@wasted.cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 14, 2016 at 10:56:03PM +0300, Sergei Shtylyov wrote:
> The  driver has the *default* case doing nothing in the *switch* statement
> with an integer expression -- remove it.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Reviewed-by: Simon Horman <horms+renesas@verge.net.au>
