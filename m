From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [PATCH] Make XFRM optional
Date: Mon, 04 Aug 2003 08:50:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2E80CD.3090206@us.ibm.com>
References: <20030804125022.GA8167@averell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20030804125022.GA8167@averell>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> Only compile in the xfrm subsystem when it's needed by any config options.
> 
> This avoids some code/data structure bloat in case you don't use IP 
> tunneling or IPsec.

Yes, I would like this too, please.


thanks,
Nivedita
