From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/5] netns netfilter: per-netns arp_tables
Date: Thu, 24 Jan 2008 18:41:56 +0100
Message-ID: <4798CDE4.1010007@trash.net>
References: <20080124122852.GC27337@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	devel@openvz.org
To: Alexey Dobriyan <adobriyan@sw.ru>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080124122852.GC27337@localhost.sw.ru>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> * Propagate netns from userspace.
> * arpt_register_table() registers table in supplied netns.

Applied.
