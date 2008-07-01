From: Peter Palfrader <peter@palfrader.org>
Subject: Re: 2.6.25.6: warn_on_slowpath in tcp_input.c
Date: Tue, 1 Jul 2008 09:38:33 +0200
Message-ID: <20080701073833.GT16698@anguilla.noreply.org>
References: <20080630230954.GS16698@anguilla.noreply.org> <396556a20806301656ydc44e3ey6deb229ab69904@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adam Langley <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from anguilla.debian.or.at ([86.59.118.152]:44186 "EHLO
	anguilla.debian.or.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbYGAHif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 03:38:35 -0400
Content-Disposition: inline
In-Reply-To: <396556a20806301656ydc44e3ey6deb229ab69904@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 30 Jun 2008, Adam Langley wrote:

> On Mon, Jun 30, 2008 at 4:09 PM, Peter Palfrader <peter@palfrader.org> wrote:
> > I've had 13 or so of them since upgrading the machine to a 2.6.25 kernel
> > 20 days ago.
> 
> Which kernel was it running before?

It was running 2.6.22.17 (+ the splice fix) before that.

-- 
                           |  .''`.  ** Debian GNU/Linux **
      Peter Palfrader      | : :' :      The  universal
 http://www.palfrader.org/ | `. `'      Operating System
                           |   `-    http://www.debian.org/
