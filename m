From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/5] netns netfilter: propagate netns from userspace
Date: Tue, 22 Jan 2008 17:58:38 +0100
Message-ID: <479620BE.2090606@trash.net>
References: <20080121145424.GI27615@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	devel@openvz.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080121145424.GI27615@localhost.sw.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> .. all the way down to table searching functions.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>

Applied.

> ---
> 
>  net/ipv4/netfilter/ip_tables.c |   46 ++++++++++++++++++++---------------------
>  1 file changed, 23 insertions(+), 23 deletions(-)

What about ip6_tables etc?
