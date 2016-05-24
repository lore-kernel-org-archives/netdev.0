From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] ip6_gre: Set flowi6_proto as IPPROTO_GRE in
 xmit path.
Date: Tue, 24 May 2016 14:34:22 -0700 (PDT)
Message-ID: <20160524.143422.552507610109476444.davem@davemloft.net>
References: <1463825855-7363-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
	<1463825855-7363-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: yanhaishuang@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463825855-7363-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Date: Sat, 21 May 2016 18:17:35 +0800

> In gre6 xmit path, we are sending a GRE packet, so set fl6 proto
> to IPPROTO_GRE properly.
> 
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

Applied.
