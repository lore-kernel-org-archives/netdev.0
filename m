From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 01/38] netns nf: remove nf_*_net() wrappers
Date: Thu, 04 Sep 2008 17:56:37 +0200
Message-ID: <48C00535.60909@trash.net>
References: <20080821215657.GA31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080821215657.GA31136@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

adobriyan@gmail.com wrote:
> Now that dev_net() exists, the usefullness of them is even less. Also they're
> a big problem in resolving circular header dependencies necessary for
> NOTRACK-in-netns patch. See below.

Applied, thanks.
