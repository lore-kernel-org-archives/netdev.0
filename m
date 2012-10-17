From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: Question about Mellanox FW reporting (incorrect) port types
Date: Wed, 17 Oct 2012 21:22:30 +0200
Message-ID: <CAJZOPZ+T7paqVe12n+sBw4ra8AEWCZ+W2GZ52iJY=9Hrgoxuaw@mail.gmail.com>
References: <507EDC5D.4070602@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Yishai Hadas <yishaih@dev.mellanox.co.il>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:54281 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756591Ab2JQTWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 15:22:30 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so5712163iag.19
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2012 12:22:30 -0700 (PDT)
In-Reply-To: <507EDC5D.4070602@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcelo Ricardo Leitner <mleitner@redhat.com> wrote:
>
> [...] So my questions are: is it possible to the firmware report a wrong port type like
> that? Is it somehow configurable by sysadmin (via fw update, ..), can we flip that byte
> or is it a manufacturing issue?


I'm not sure, Yevgeny/Yishai do you have any insights here?

> I can't try upstream driver

why?! netdev is dealing with upstream, isn't it?

Or.
