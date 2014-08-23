From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: use reciprocal_scale() helper
Date: Sat, 23 Aug 2014 12:21:36 -0700 (PDT)
Message-ID: <20140823.122136.1226327468462504584.davem@davemloft.net>
References: <1408820334-2088-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	hannes@stressinduktion.org
To: dborkman@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1408820334-2088-1-git-send-email-dborkman@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sat, 23 Aug 2014 20:58:54 +0200

> Replace open codings of (((u64) <x> * <y>) >> 32) with reciprocal_scale().
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks Daniel.
