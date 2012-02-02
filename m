From: Roland Stigge <stigge@antcom.de>
Subject: Re: [PATCH] ARM: LPC32xx: Ethernet support
Date: Thu, 02 Feb 2012 16:31:57 +0100
Message-ID: <4F2AAC6D.9020600@antcom.de>
References: <1328195086-20130-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, alexander.h.duyck@intel.com,
	eilong@broadcom.com, ian.campbell@citrix.com,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from antcom.de ([188.40.178.216]:42085 "EHLO chuck.antcom.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932077Ab2BBPlm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Feb 2012 10:41:42 -0500
In-Reply-To: <1328195086-20130-1-git-send-email-stigge@antcom.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 02/02/2012 04:04 PM, stigge@antcom.de wrote:
> This patch adds ethernet support to the LPC32xx ARM architecture.
> 
> Signed-off-by: Roland Stigge <stigge@antcom.de>

This is part of a series of patches to make the lpc32xx architecture
more usable. Without some of the other fixes in the patches, the
ethernet driver alone isn't very useful.

For compiling and testing, please also consider the other patches at

http://antcom.de/lpc32xx/

You can also compare my lpc32xx based branch "work92105" at
http://git.antcom.de/, repo linux-2.6.

I can also forward the other (non-network related) LPC32xx-patches to
you if you like.

Thanks in advance!

Roland
