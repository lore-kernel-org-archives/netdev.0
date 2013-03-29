From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cirrus: cs89x0: remove two obsolete Kconfig macros
Date: Fri, 29 Mar 2013 15:40:51 -0400 (EDT)
Message-ID: <20130329.154051.48484741575211147.davem@davemloft.net>
References: <1364554290.1345.52.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: pebolle@tiscali.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364554290.1345.52.camel@x61.thuisdomein>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Bolle <pebolle@tiscali.nl>
Date: Fri, 29 Mar 2013 11:51:30 +0100

> The CONFIG_ARCH_IXDP2X01 and CONFIG_MACH_IXDP2351 Kconfig macros are
> unused since the ixp23xx and ixp2000 platforms were removed in v3.5. So
> remove the last code still depending on these macros. And since
> CS89x0_NONISA_IRQ was only set if either of these two macros was defined
> we can also remove that macro and the code depending on it.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>

Applied, thanks Paul.
