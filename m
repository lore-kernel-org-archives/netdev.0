From: Sajith P V <sajithpv@gmail.com>
Subject: Re: [PATCH] i.MX31: Fixing cs89x0 network building to i.MX31ADS
Date: Thu, 2 Apr 2009 17:36:21 +0530
Message-ID: <155d92380904020506g36167548h915d07c69abd7c9f@mail.gmail.com>
References: <37367b3a0903241018h7ff3302fi83cf1fcb21a3114d@mail.gmail.com>
	 <37367b3a0903300714g40a108d3j59a3b56ee9cda2bf@mail.gmail.com>
	 <20090330143155.GA20101@pengutronix.de>
	 <37367b3a0903301315u51787ebcl119ed295e373a1e4@mail.gmail.com>
	 <20090331075951.GF22913@pengutronix.de>
	 <37367b3a0903310636x3c8d8eban4310018c3d1b40b@mail.gmail.com>
	 <155d92380904010454l34c57687j67e6805dafcb92ef@mail.gmail.com>
	 <20090402091102.GJ4337@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Carvalho de Assis <acassis@gmail.com>,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	Sascha Hauer <s.hauer@pengutronix.de>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:42384 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753684AbZDBMGX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 08:06:23 -0400
Received: by wf-out-1314.google.com with SMTP id 29so603777wff.4
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2009 05:06:21 -0700 (PDT)
In-Reply-To: <20090402091102.GJ4337@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Russell,

On Thu, Apr 2, 2009 at 2:41 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> On Wed, Apr 01, 2009 at 05:24:27PM +0530, Sajith P V wrote:
>> cs89x0 media =A0IRQ 61, programmed I/O, MAC 00:00:00:00:00:00
>
> Also note that this MAC address is invalid, so you'll need to use ifc=
onfig
> to set a valid MAC address before trying to bring the interface up.
>

Thanks. I will check this once my console is up.

Regards,
Sajith
