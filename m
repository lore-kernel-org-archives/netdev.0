From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [SKGE]: Fix deadlock in skge_tx_timeout
Date: Tue, 27 Feb 2007 09:42:37 -0800
Message-ID: <20070227094237.72274f8a@freekitty>
References: <45E08D27.4030509@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42229 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751700AbXB0Rmm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 12:42:42 -0500
In-Reply-To: <45E08D27.4030509@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 24 Feb 2007 20:08:23 +0100
Patrick McHardy <kaber@trash.net> wrote:

This looks correct. Probably never hit it since the hardware for skge
is more stable and doesn't timeout.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
