From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH v2.6.22-rc5] cxgb2: handle possible NULL pointer
 dereferencing, take 2
Date: Mon, 25 Jun 2007 17:38:27 -0700
Message-ID: <20070625173827.4dc154cb@freepuppy.localdomain.hemminger.net>
References: <a901b49a0706210553r58ea8743gc565fcca1a87b58f@mail.gmail.com>
	<a901b49a0706210618q7c22cbe0jd6f7e052a8e05a97@mail.gmail.com>
	<20070625153450.c5f535ca.akpm@linux-foundation.org>
	<46804C9B.5060102@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	pradeep singh <pradeep.rautela@gmail.com>, trivial@kernel.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38009 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752221AbXFZAiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 20:38:46 -0400
In-Reply-To: <46804C9B.5060102@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 25 Jun 2007 19:15:39 -0400
Jeff Garzik <jeff@garzik.org> wrote:

> Andrew Morton wrote:
> > (Who maintains this driver now?)
> 
> 
> It was abandonware from the beginning of its life.  Stephen H and 
> Francois R did a bunch of cleanups most recently.
> 
> 	Jeff

Have a couple of loaner boards, but really don't have the urge to maintain
the driver. But I will retest any changes/cleanups.
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
