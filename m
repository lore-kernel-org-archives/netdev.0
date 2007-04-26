From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [BUG REPORT] 2.6.21-rc7 - Yukon-EC Ultra <-> sky2 driver bug(s)
Date: Thu, 26 Apr 2007 15:35:17 -0700
Message-ID: <20070426153517.2a78c3c4@dxpl.pdx.osdl.net>
References: <1005889901.20070426035905@3d-io.com>
	<20070426130339.109e42ea@freekitty>
	<1901675644.20070427003443@3d-io.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: speedy <speedy@3d-io.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:39732 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755139AbXDZWib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 18:38:31 -0400
In-Reply-To: <1901675644.20070427003443@3d-io.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 27 Apr 2007 00:34:43 +0200
speedy <speedy@3d-io.com> wrote:

> Hello Stephen,
> 
> Thursday, April 26, 2007, 10:03:39 PM, you wrote:
> 
> SH> On Thu, 26 Apr 2007 03:59:05 +0200
> SH> speedy <speedy@3d-io.com> wrote:
> 
> >> Kernel: 2.6.21-rc7
> >> Device: Yukon-EC Ultra (0xb4) rev 2 [integrated on Gigabyte GA-965P-DQ6]
> >> OS: Ubuntu 7.04 (Feisty Fawn)

I have that motherboard, that is why I blacklisted it..
Neither my driver (or the vendor driver works). Right now I suspect some
problem unique to full x86-64 mode. Windows runs it in i386 mode.
