From: Steven Whitehouse <steve@chygwyn.com>
Subject: Re: [DECNET]: Add support for fwmark masks in routing rules
Date: Fri, 25 Aug 2006 13:26:40 +0100
Message-ID: <20060825122640.GA7213@souterrain.chygwyn.com>
References: <44EEE994.90404@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	patrick@tykepenguin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from souterrain.chygwyn.com ([194.39.143.233]:23169 "EHLO
	souterrain.chygwyn.com") by vger.kernel.org with ESMTP
	id S1750762AbWHYMWM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 08:22:12 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44EEE994.90404@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, Aug 25, 2006 at 02:14:12PM +0200, Patrick McHardy wrote:

> [DECNET]: Add support for fwmark masks in routing rules
> 
> Add support for fwmark masks. For compatibility a mask of 0xFFFFFFFF is used
> when a mark value != 0 is sent without a mask.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
Acked-by: Steven Whitehouse <steve@chygwyn.com>

Looks good,

Steve.
