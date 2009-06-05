From: Sergey Lapin <slapin@ossfans.org>
Subject: Re: [PATCH 3/5] net: add NL802154 interface for configuration of
	802.15.4 devices
Date: Fri, 5 Jun 2009 13:46:19 +0400
Message-ID: <20090605094619.GB23085@build.ossfans.org>
References: <1244168990-28355-4-git-send-email-dbaryshkov@gmail.com> <1244184737.22576.94.camel@johannes.local> <20090605071529.GA7064@doriath.ww600.siemens.net> <20090605.005418.07362083.davem@davemloft.net> <20090605091229.GA25280@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, sfr@canb.auug.org.au
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from build.ossfans.org ([67.223.233.67]:53561 "EHLO
	build.ossfans.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbZFEJqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 05:46:44 -0400
Content-Disposition: inline
In-Reply-To: <20090605091229.GA25280@doriath.ww600.siemens.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -0,0 +1,523 @@
> +/*
> + * Netlink inteface for IEEE 802.15.4 stack
> + *
> + * Copyright 2007, 2008 Siemens AG
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2
> + * as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License along
> + * with this program; if not, write to the Free Software Foundation, Inc.,
> + * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
> + *
> + * Written by:
> + * Sergey Lapin <sergey.lapin@siemens.com>
Dmitry, please toss all my @siemens.com addresses from all patches, since my
access is already disabled and it's pointless to have invalid emails
in source tree. Please replace them with @ossfans.org ones.

