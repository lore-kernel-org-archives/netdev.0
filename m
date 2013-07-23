From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next v2 6/6] openvswitch: Add vxlan tunneling support.
Date: Wed, 24 Jul 2013 00:03:46 +0300
Message-ID: <CAJZOPZJH3UXC6BKLtUsDFAOvr=5cFHaY5_dSstBZNi-=HL_aiA@mail.gmail.com>
References: <1374603775-15605-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	Jesse Gross <jesse@nicira.com>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:54246 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753211Ab3GWVDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 17:03:47 -0400
Received: by mail-qa0-f46.google.com with SMTP id bq6so1377229qab.19
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 14:03:46 -0700 (PDT)
In-Reply-To: <1374603775-15605-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 23, 2013 at 9:22 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
[...]
> --- /dev/null
> +++ b/net/openvswitch/vport-vxlan.c
[...]
> +#ifdef CONFIG_OPENVSWITCH_VXLAN

this should go to the makefile
