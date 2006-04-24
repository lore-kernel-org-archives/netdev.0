From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Congestion Avoidance Monitoring Tools
Date: Mon, 24 Apr 2006 10:39:19 -0700
Message-ID: <20060424103919.36707728@localhost.localdomain>
References: <1145597174.12413.17.camel@piet2.bluelane.com>
	<20060421081917.34ea952b@localhost.localdomain>
	<20060423225235.GA23714@c3po.0xdef.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: piet@bluelane.com, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:30169 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751052AbWDXRkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2006 13:40:22 -0400
To: Hagen Paul Pfeifer <hagen@jauu.net>
In-Reply-To: <20060423225235.GA23714@c3po.0xdef.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 24 Apr 2006 00:52:35 +0200
Hagen Paul Pfeifer <hagen@jauu.net> wrote:

> * Stephen Hemminger | 2006-04-21 08:19:17 [-0700]:
> 
> >2.6.13 still had lots of problems, things didn't really get working
> >right till 2.6.15 or later. Especially with TSO.
> 
> --verbose?
> 
> >I have a tool using kprobe's see http://developer.osdl.org/shemminger/prototypes/tcpprobe.tar.gz
> >I try to keep it up to date with current kernel and build process, last used it
> >on 2.6.16.
> 
> wget http://developer.osdl.org/shemminger/prototypes/tcpprobe.tar.gz
> 
> Ended with following error code: ;-)
> 
> 00:32:48 ERROR 403: Forbidden.
> 
> HGN
> 

Fixed
