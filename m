From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [PATCH v3] Make the pr_*() family of macros in kernel.h complete
Date: Wed, 12 Sep 2007 20:04:20 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0709122003410.22467@fbirervta.pbzchgretzou.qr>
References: <11896151802410-git-send-email-Emilian.Medve@Freescale.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	i2c@lm-sensors.org, linux-omap-open-source@linux.omap.com
To: Emil Medve <Emilian.Medve@Freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:54583 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765554AbXILSEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 14:04:22 -0400
In-Reply-To: <11896151802410-git-send-email-Emilian.Medve@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Sep 12 2007 11:39, Emil Medve wrote:
>
>Other/Some pr_*() macros are already defined in kernel.h, but pr_err() was defined
>multiple times in several other places

Note http://lkml.org/lkml/2007/8/4/30 .
