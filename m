From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [netfilter-core] [PATCH] netfilter: unnecessary to check whether
 ip6_route_output() returns NULL
Date: Thu, 7 Apr 2016 18:53:42 +0200
Message-ID: <20160407165342.GA5598@salvia>
References: <1459692213-3948-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>, netdev@vger.kernel.org,
	coreteam@netfilter.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1459692213-3948-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 03, 2016 at 10:03:33PM +0800, Haishuang Yan wrote:
> ip6_route_output() never returns NULL, so it is not appropriate to
> check if the return value is NULL.

Applied, thanks.
