From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_output: fix sparse warning for tcp_wfree
Date: Mon, 06 Aug 2012 13:30:08 -0700 (PDT)
Message-ID: <20120806.133008.1786133868751305467.davem@davemloft.net>
References: <1344108689-17896-1-git-send-email-silviupopescu1990@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org
To: silviupopescu1990@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344108689-17896-1-git-send-email-silviupopescu1990@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Date: Sat,  4 Aug 2012 22:31:29 +0300

> Fix sparse warning:
> 	* symbol 'tcp_wfree' was not declared. Should it be static?
> 
> Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>

Applied.
