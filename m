From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] dst allocation problem in ndisc
Date: Thu, 10 Jun 2004 11:12:28 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040610.111228.77019042.yoshfuji@linux-ipv6.org>
References: <200403311326.43647.mashirle@us.ibm.com>
	<200405261308.54281.mashirle@us.ibm.com>
	<200406091600.30568.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, xma@us.ibm.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mashirle@us.ibm.com
In-Reply-To: <200406091600.30568.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200406091600.30568.mashirle@us.ibm.com> (at Wed, 9 Jun 2004 16:00:29 -0700), Shirley Ma <mashirle@us.ibm.com> says:

> Here is the patch against 2.6.6 kernel. Please review this patch.

Basically, I agree.
One thing: you can minimize diff using function declaration.

--yoshfuji
