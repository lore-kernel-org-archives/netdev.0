From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH linux-next] ipv6: fix missing braces in
 ip6_tnl_add_linklocal
Date: Wed, 21 Aug 2013 20:05:33 -0700 (PDT)
Message-ID: <20130821.200533.2282704635493963288.davem@davemloft.net>
References: <1377123597-26515-1-git-send-email-vincent.stehle@laposte.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	dingtianhong@huawei.com
To: vincent.stehle@laposte.net
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1377123597-26515-1-git-send-email-vincent.stehle@laposte.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I already reverted the change in question.
