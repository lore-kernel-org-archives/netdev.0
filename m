From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: phy: smsc: Move SMSC PHY constants to
 <linux/smscphy.h>
Date: Tue, 03 Jan 2012 13:45:49 -0500 (EST)
Message-ID: <20120103.134549.1973511401092214707.davem@davemloft.net>
References: <1325524131-14585-1-git-send-email-martinez.javier@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, ben@decadent.org.uk,
	eballetbo@iseebcn.com, netdev@vger.kernel.org
To: martinez.javier@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41390 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537Ab2ACSqE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 13:46:04 -0500
In-Reply-To: <1325524131-14585-1-git-send-email-martinez.javier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Javier Martinez Canillas <martinez.javier@gmail.com>
Date: Mon,  2 Jan 2012 18:08:50 +0100

> +/***************************************************************************
> + *
> + * This program is free software; you can redistribute it and/or
> + * modify it under the terms of the GNU General Public License
> + * as published by the Free Software Foundation; either version 2
> + * of the License, or (at your option) any later version.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
> + *
> + ***************************************************************************/

Come on, I normally don't get into how people do copyrights in files,
but this is a file with 13 trivial defines, and the whole kernel
source tree is explicitly GPL V2'd by the top-level COPYING file.

So this thing is over the top.
