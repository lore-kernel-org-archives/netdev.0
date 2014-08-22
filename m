From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: isdn: eicon: xdi_msg.h: Fix typo in #ifndef
Date: Fri, 22 Aug 2014 11:31:58 -0700 (PDT)
Message-ID: <20140822.113158.256044299285972431.davem@davemloft.net>
References: <1408725554-2524-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mac@melware.de, isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@rasmusvillemoes.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408725554-2524-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Fri, 22 Aug 2014 18:39:14 +0200

> Test for definedness of the macro which is actually defined (the
> change is hard to see: it is s/SSS/SSA/).
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Applied.
