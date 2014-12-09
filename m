From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/20] dmfe: fix misspelling of current function in
 string
Date: Tue, 09 Dec 2014 16:14:31 -0500 (EST)
Message-ID: <20141209.161431.2295598346088286047.davem@davemloft.net>
References: <1417980062-25151-1-git-send-email-Julia.Lawall@lip6.fr>
	<1417980062-25151-5-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grundler@parisc-linux.org, kernel-janitors@vger.kernel.org,
	linux@rasmusvillemoes.dk, joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417980062-25151-5-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun,  7 Dec 2014 20:20:46 +0100

> The function name contains cleanup, not clean.
> 
> This was done using Coccinelle, including the use of Levenshtein distance,
> as proposed by Rasmus Villemoes.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
