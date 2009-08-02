From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] IPVS: use pr_err and friends instead of
 IP_VS_ERR and friends
Date: Sun, 02 Aug 2009 12:55:35 -0700 (PDT)
Message-ID: <20090802.125535.13404927.davem@davemloft.net>
References: <20090731113155.22420.59863.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, joe@perches.com, jengelh@medozas.de,
	horms@verge.net.au
To: heder@google.com
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <20090731113155.22420.59863.stgit@jazzy.zrh.corp.google.com>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Eder <heder@google.com>
Date: Fri, 31 Jul 2009 13:31:55 +0200

> Since pr_err and friends are used instead of printk there is not point
> in keeping IP_VS_ERR and friends.  Furthermore make use of '__func__'
> instead of hard coded function names.
> 
> Signed-off-by: Hannes Eder <heder@google.com>

This patch does not apply to net-next-2.6.
