From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: mii-tool gigabit support.
Date: Tue, 26 Sep 2006 15:09:47 -0700
Message-ID: <20060926150947.3d538547@freekitty>
References: <20060926145113.7a6791c8@freekitty>
	<4519A1D6.1050802@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dhinds@pcmcia.sourceforge.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:51351 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932439AbWIZWJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 18:09:56 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4519A1D6.1050802@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 26 Sep 2006 17:55:34 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Stephen Hemminger wrote:
> > The mii-tool utility seems to be abandoned and unmaintained?
> > 
> > Here is a version that does standard 1000baseT support.
> > 	http://developer.osdl.org/shemminger/prototypes/mii-tool.tar.bz2
> 
> Not really.  I would rather leave it as-is, and deprecate it in favor of 
> ethtool.
>

It does make a handy debug tool when driver isn't doing MII correctly.

-- 
Stephen Hemminger <shemminger@osdl.org>
