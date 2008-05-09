From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/3] [TC/U32] Restore old output of u32
Date: Fri, 9 May 2008 15:51:25 -0700
Message-ID: <20080509155125.1251578d@extreme>
References: <1208702744.12249.51.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:49246 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754792AbYEIWvh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2008 18:51:37 -0400
In-Reply-To: <1208702744.12249.51.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 20 Apr 2008 10:45:44 -0400
jamal <hadi@cyberus.ca> wrote:

> 
> This is a repeat of the first one i sent already..
> 
> cheers,
> jamal

I applied these but I changed "-cooked" to "-pretty", just
personal taste, cooked sounds too cute and leftover unix geeky.

Also, added documentation to the tc.8 man page for this.
