From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 linux-next] net/ibm/emac: use swap() in
 emac_make_bootlist()
Date: Thu, 11 Jun 2015 15:21:41 -0700 (PDT)
Message-ID: <20150611.152141.1304284920026818429.davem@davemloft.net>
References: <1433953997-24693-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Julia.Lawall@lip6.fr,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433953997-24693-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Wed, 10 Jun 2015 18:33:16 +0200

> Use kernel.h macro definition.
> 
> Thanks to Julia Lawall for Coccinelle scripting support.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
