From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 1/7] netns ebtables: part 1
Date: Wed, 15 Oct 2008 08:25:09 +0400
Message-ID: <20081015042509.GL24058@x200.localdomain>
References: <20081015042014.GE24058@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@osdl.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081015042014.GE24058@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 15, 2008 at 08:20:14AM +0400, Alexey Dobriyan wrote:
> One needs to add ".netns_ok = 1" to igmp_protocol to test all of this
> with ebtables() in netns.

Contains 80-column violations, I forgot about damn script again :^)
