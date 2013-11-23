From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sit: generate icmpv6 error when receiving icmpv4 error
Date: Sat, 23 Nov 2013 14:48:18 -0800 (PST)
Message-ID: <20131123.144818.2246886107340272240.davem@davemloft.net>
References: <1385133800-1562-1-git-send-email-ghorbel@pivasoftware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ou.ghorbel@gmail.com
To: ghorbel@pivasoftware.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385133800-1562-1-git-send-email-ghorbel@pivasoftware.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oussama Ghorbel <ghorbel@pivasoftware.com>
Date: Fri, 22 Nov 2013 16:23:20 +0100

> Send icmpv6 error with type "destination unreachable" and code
> "address unreachable" when receiving icmpv4 error and sufficient
> data bytes are available
> This patch enhances the compliance of sit tunnel with section 3.4 of
> rfc 4213
> 
> Signed-off-by: Oussama Ghorbel <ghorbel@pivasoftware.com>

Applied.
