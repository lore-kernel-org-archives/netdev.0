From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next v1 3/3] net/mlx4_en: Set number of rx/tx channels
 using ethtool
Date: Sun, 2 Dec 2012 14:23:52 +0200
Message-ID: <CAJZOPZJ7OCyZtrhD+DjTBMdBECe+at-jtoRpUOXgw3YJyQ740w@mail.gmail.com>
References: <1354216903-830-4-git-send-email-amirv@mellanox.com>
	<1354319925.2640.3.camel@bwh-desktop.uk.solarflarecom.com>
	<CAJZOPZK98UOsK2HFSC3V6fdzvJfWVKg6pZzxptE97MTgOAk7-w@mail.gmail.com>
	<20121201.112555.1561917161372059709.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bhutchings@solarflare.com, amirv@mellanox.com,
	ogerlitz@mellanox.com, oren@mellanox.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:34096 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752350Ab2LBMXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2012 07:23:53 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so2839973ieb.19
        for <netdev@vger.kernel.org>; Sun, 02 Dec 2012 04:23:52 -0800 (PST)
In-Reply-To: <20121201.112555.1561917161372059709.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 1, 2012 at 6:25 PM, David Miller <davem@davemloft.net> wrote:

> He's saying that you need to carefully validate the arguments, not
> that appropriate permissions haven't been checked.

OK, understood.

Or.
