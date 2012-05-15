From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH, v2] xfrm: make xfrm_algo.c a module
Date: Tue, 15 May 2012 13:14:36 -0400 (EDT)
Message-ID: <20120515.131436.1766404788147122977.davem@davemloft.net>
References: <4FB260D80200007800083C91@nat28.tlf.novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: JBeulich@suse.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FB260D80200007800083C91@nat28.tlf.novell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jan Beulich" <JBeulich@suse.com>
Date: Tue, 15 May 2012 12:57:44 +0100

> By making this a standalone config option (auto-selected as needed),
> selecting CRYPTO from here rather than from XFRM (which is boolean)
> allows the core crypto code to become a module again even when XFRM=y.
> 
> Signed-off-by: Jan Beulich <jbeulich@suse.com>

Applied.
