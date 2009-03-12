From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [RFC v2 2/7] net: netfilter conntrack - add per-net functionality
 for DCCP protocol
Date: Thu, 12 Mar 2009 09:54:31 +0100
Message-ID: <49B8CDC7.5070105@free.fr>
References: <20090311205706.141086138@gmail.com> <20090311210817.172204517@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, xemul@openvz.org,
	adobriyan@gmail.com, Cyrill Gorcunov <gorcunov@openvz.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090311210817.172204517@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cyrill Gorcunov wrote:
> Module specific data moved into per-net site and being allocated/freed
> during net namespace creation/deletion.
>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> ---
>   
Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>
