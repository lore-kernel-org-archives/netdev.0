From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: netlink circular locking dependency
Date: Tue, 17 Jun 2008 13:43:03 +0000
Message-ID: <20080617134303.GC4632@ff.dom.local>
References: <20080616213417.GA14988@ami.dom.local> <4856DF91.30606@trash.net> <1213667154.21932.47.camel@violet.holtmann.net> <4857B30B.8020809@trash.net> <20080617130910.GA4632@ff.dom.local> <4857B720.1070302@trash.net> <20080617132410.GB4632@ff.dom.local> <4857BBB6.6010709@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>, Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:4001 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757328AbYFQNjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 09:39:05 -0400
Received: by yw-out-2324.google.com with SMTP id 9so3396462ywe.1
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 06:38:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4857BBB6.6010709@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 17, 2008 at 03:27:18PM +0200, Patrick McHardy wrote:
...
> I guess that might work. But simply using module references to
> prevent the module from going away while the mutex is not held
> doesn't appear to be more complicated.

O.K.

Jarek P.
