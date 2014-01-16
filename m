From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v6 net-next 1/4] sh_eth: Use bool as return type of sh_eth_is_gether()
Date: Thu, 16 Jan 2014 19:19:46 +0400
Message-ID: <52D7F892.1050708@cogentembedded.com>
References: <1389839656-10932-1-git-send-email-horms+renesas@verge.net.au> <1389839656-10932-2-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Joe Perches <joe@perches.com>
To: Simon Horman <horms+renesas@verge.net.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1389839656-10932-2-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 16-01-2014 6:34, Simon Horman wrote:

> Return a boolean and use true and false.

    You're not using them explicitly anymore. I'd update the changelog
with converting the function to one-liner.

> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

WBR, Sergei

