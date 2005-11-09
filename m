From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Fix fallout from CONFIG_IPV6_PRIVACY
Date: Wed, 09 Nov 2005 13:05:58 -0800 (PST)
Message-ID: <20051109.130558.34471475.davem@davemloft.net>
References: <17265.16378.77270.7493@berry.gelato.unsw.EDU.AU>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161231AbVKIVGB@vger.kernel.org>
To: peterc@gelato.unsw.edu.au
In-Reply-To: <17265.16378.77270.7493@berry.gelato.unsw.EDU.AU>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 9 Nov 2005 11:16:58 +1100

> Trying to build today's 2.6.14+git snapshot gives undefined references
> to use_tempaddr
> 
> Looks like an ifdef got left out.
> 
> Signed-off-by: Peter Chubb <peterc@gelato.unsw.edu.au>

Applied, thanks Peter.
