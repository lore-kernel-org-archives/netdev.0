From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: netconsole as normal console for userspace messages?
Date: Tue, 1 Sep 2009 10:16:12 +0000
Message-ID: <20090901101612.GB5222@ff.dom.local>
References: <200908300212.37966.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Matt Mackall <mpm@selenic.com>
To: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:39570 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbZIAKQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 06:16:15 -0400
Received: by fxm17 with SMTP id 17so3392362fxm.37
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2009 03:16:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200908300212.37966.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30-08-2009 02:12, Arkadiusz Miskiewicz wrote:
> Hi,
Hi,

> 
> Can netconsole be somehow used to see userspace messages, too? Something 
> similar to console=ttySX... just =netconsole.
> 

AFAIK it can't, but AFAICR some time ago the netconsole maintainer
gave some hope to some Debian guy with a similar question.

Jarek P.
