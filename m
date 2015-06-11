From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 linux-next] net/mlx4_core: use swap() in
 mlx4_make_profile()
Date: Thu, 11 Jun 2015 15:21:59 -0700 (PDT)
Message-ID: <20150611.152159.1060994324931897233.davem@davemloft.net>
References: <1433953993-24623-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Julia.Lawall@lip6.fr,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433953993-24623-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Wed, 10 Jun 2015 18:33:13 +0200

> Use kernel.h macro definition.
> 
> Thanks to Julia Lawall for Coccinelle scripting support.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
