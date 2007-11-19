From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch 00/22] DM9000 updates for 2.6.25
Date: Mon, 19 Nov 2007 15:04:31 -0800
Message-ID: <20071119150431.43b09d0c@freepuppy.rosehill>
References: <20071119203910.687238131@fluff.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vince@simtec.co.uk
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56719 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755895AbXKSXFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 18:05:37 -0500
In-Reply-To: <20071119203910.687238131@fluff.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 19 Nov 2007 20:39:10 +0000
Ben Dooks <ben-linux@fluff.org> wrote:

> This is my current proposed patch series to the DM9000
> driver for both general cleanups, support for ethtool
> and to make the code better.
> 

You could also change all instances of dev->priv with netdev_priv(dev).


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
