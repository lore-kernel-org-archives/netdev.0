From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver
 configuration.
Date: Wed, 10 Jun 2009 11:02:46 -0700
Message-ID: <1244656967.14695.12.camel@Joe-Laptop.home>
References: <20090610173243.17262.91308.stgit@srv002.fuzzey.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nico@cam.org
To: Martin Fuzzey <mfuzzey@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:2571 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752493AbZFJSCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 14:02:49 -0400
In-Reply-To: <20090610173243.17262.91308.stgit@srv002.fuzzey.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-06-10 at 19:34 +0200, Martin Fuzzey wrote:
> +static struct choice port_choices[] = {
> +	{"tp", PORT_TP},
> +	{"aui", PORT_AUI},
> +	{"bnc", PORT_BNC},
> +	{"mii", PORT_MII},
> +	{"fibre", PORT_FIBRE},
> +};

perhaps add

	{"fiber", PORT_FIBRE},

for us poor spelling folk across the pond...

