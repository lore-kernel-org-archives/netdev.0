From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/20] hp100: fix misspelling of current function in
 string
Date: Tue, 09 Dec 2014 16:13:18 -0500 (EST)
Message-ID: <20141209.161318.2286665465014165364.davem@davemloft.net>
References: <1417980062-25151-1-git-send-email-Julia.Lawall@lip6.fr>
	<1417980062-25151-13-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: perex@perex.cz, kernel-janitors@vger.kernel.org,
	linux@rasmusvillemoes.dk, joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417980062-25151-13-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun,  7 Dec 2014 20:20:54 +0100

> Replace a misspelled function name by %s and then __func__.
> 
> This was done using Coccinelle, including the use of Levenshtein distance,
> as proposed by Rasmus Villemoes.
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
