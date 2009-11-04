From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] trivial: remove duplicated MIN macro from tehuti.
Date: Wed, 04 Nov 2009 05:07:34 -0800 (PST)
Message-ID: <20091104.050734.211699606.davem@davemloft.net>
References: <1257253829-4531-1-git-send-email-tfransosi@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, yanghy@cn.fujitsu.com, baum@tehutinetworks.net,
	andy@greyhouse.net, shemminger@vyatta.com,
	apkm@linux-fundation.org, ben@decadent.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tfransosi@gmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756073AbZKDNHS@vger.kernel.org>
In-Reply-To: <1257253829-4531-1-git-send-email-tfransosi@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thiago Farina <tfransosi@gmail.com>
Date: Tue,  3 Nov 2009 08:10:29 -0500

> Since the kernel api already has the macro "min",
> just use it instead of declaring another one.
> 
> Signed-off-by: Thiago Farina <tfransosi@gmail.com>

Applied to net-next-2.6, thanks!
