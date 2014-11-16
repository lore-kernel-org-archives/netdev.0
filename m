From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] net: dsa: replace count*size kzalloc by
 kcalloc
Date: Sun, 16 Nov 2014 14:44:01 -0500 (EST)
Message-ID: <20141116.144401.2049812598100240354.davem@davemloft.net>
References: <1415990303-28764-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415990303-28764-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Fri, 14 Nov 2014 19:38:23 +0100

> kcalloc manages count*sizeof overflow.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
