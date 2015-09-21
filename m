From: Peter Korsgaard <peter@korsgaard.com>
Subject: Re: [PATCH] usbnet: New driver for QinHeng CH9200 devices
Date: Mon, 21 Sep 2015 12:08:32 +0200
Message-ID: <CACXmVibdHCCbyBJfX2q8=jt562R6whq-Btij27p2khoS1RUyQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matthew Garrett <mjg59@coreos.com>, netdev@vger.kernel.org,
	Matthew Garrett <mjg59@srcf.ucam.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:35654 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732AbbIUKIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 06:08:32 -0400
Received: by oiww128 with SMTP id w128so55266217oiw.2
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 03:08:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 21, 2015 at 8:36 AM, Oliver Neukum <oneukum@suse.com> wrote:

> surprisingly nice for a vendor driver. It even covers endianness
> correctly. I'd say that the remaining issues will be easy to fix
> and that would be easier on a merged driver.

Agreed. It might be related to the fact that it seems to be based on
sr9700.c (which in term is largely derrived from dm9601.c) ;)

But that's fine.

-- 
Bye, Peter Korsgaard
