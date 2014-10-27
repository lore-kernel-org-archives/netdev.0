From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipv4: remove set but unused variable sha
Date: Mon, 27 Oct 2014 16:04:21 -0400 (EDT)
Message-ID: <20141027.160421.346832095714086308.davem@davemloft.net>
References: <1414433002-29106-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414433002-29106-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Mon, 27 Oct 2014 19:03:22 +0100

> unsigned char *sha (source) was already in original git version
>  but was never used.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
