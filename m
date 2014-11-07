From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] asix: Do full reset during ax88772_bind
Date: Fri, 07 Nov 2014 11:32:20 -0500 (EST)
Message-ID: <20141107.113220.1115772753122037844.davem@davemloft.net>
References: <1415288981-3862-1-git-send-email-ckeepax@opensource.wolfsonmicro.com>
	<C89EFD3CD56F64468D3D206D683A8D22039FFEDE@ldam-msx2.fugro-nl.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ckeepax@opensource.wolfsonmicro.com, jeffrey.t.kirsher@intel.com,
	emilgoode@gmail.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: M.Stam@fugro.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C89EFD3CD56F64468D3D206D683A8D22039FFEDE@ldam-msx2.fugro-nl.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Stam, Michel [FINT]" <M.Stam@fugro.nl>
Date: Fri, 7 Nov 2014 09:27:26 +0100

> Please add;
> 
> Tested-by: Michel Stam  <m.stam@fugro.nl>

You're making two critical mistakes here in how you are replying to
this patch.

First, do not top post.  Quote the commit message, then add your
Tested-by or other tag afterwards.

And most importantly, do not provide the entire patch again.  That
makes a brand new entry in patchwork, rather than adding your
Tested-by to the original patch.

These mistakes make more work for everyone trying to get this
change into the tree, including me.  So please respond and
discuss patches like everyone else does by not top-posting and
not posting the entire patch in your response.

Thanks.
