From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 1/2] net, bridge: align br_nf_ops assignment
Date: Thu, 9 Jul 2009 12:55:00 -0700
Message-ID: <20090709125500.5f8cf2a0@nehalam>
References: <20090704061156.658235360@openvz.org>
	<20090704062320.774818680@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Cyrill Gorcunov <gorcunov@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:39898 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755024AbZGIUlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 16:41:25 -0400
In-Reply-To: <20090704062320.774818680@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 04 Jul 2009 10:11:57 +0400
Cyrill Gorcunov <gorcunov@openvz.org> wrote:

> No functional change -- just for easier reading.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> ---
>  net/bridge/br_netfilter.c |   96 ++++++++++++++++++++++++++--------------------
>  1 file changed, 56 insertions(+), 40 deletions(-)
> 


Acked-by: Stephen Hemminger <shemminger@vyatta.com>

-- 
