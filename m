From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Fri, 22 Feb 2013 18:17:03 -0300
Message-ID: <CAOMZO5AmJdgQRiQ2ia4t3tW9yJkr1NZSdkKQmoi-YAFvXaC-TA@mail.gmail.com>
References: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com>
	<loom.20130204T174808-896@post.gmane.org>
	<CAHrpEqSXhEBQpnR60mjP67gbVWNemfa3tTuoDTKipej_6QQ62g@mail.gmail.com>
	<loom.20130205T111507-687@post.gmane.org>
	<CAHrpEqTsUjWjxY3_C4kGL_S0pgpYawgBaSip3DEnZd3CY1hn0A@mail.gmail.com>
	<51125F28.4000409@intel.com>
	<CAHrpEqR9u5t8fZOYRq4k_vTsEORVsNwa2C_rLaxesmusY5e9-Q@mail.gmail.com>
	<loom.20130222T132206-265@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Li Frank-B20596 <B20596@freescale.com>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f170.google.com ([209.85.128.170]:48483 "EHLO
	mail-ve0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755691Ab3BVVRF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 16:17:05 -0500
Received: by mail-ve0-f170.google.com with SMTP id 14so969718vea.1
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 13:17:03 -0800 (PST)
In-Reply-To: <loom.20130222T132206-265@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jim,

On Fri, Feb 22, 2013 at 9:25 AM, Jim Baxter <jim_baxter@mentor.com> wrote:

> Hi Frank,
>
> Have you had time to have a look at this issues again?

Can you try again using the latest net tree from David Miller?
