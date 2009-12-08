From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Bugme-new] [Bug 14749] New: Kernel locks up after a few
	minutes of heavy surfing
Date: Tue, 8 Dec 2009 13:47:56 +0000
Message-ID: <20091208134756.GB8263@ff.dom.local>
References: <20091208113645.GA8263@ff.dom.local> <755510.33826.qm@web52905.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, stable@kernel.org,
	Neil Horman <nhorman@tuxdriver.com>
To: Chris Rankin <rankincj@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:48771 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755303AbZLHNrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 08:47:53 -0500
Received: by bwz27 with SMTP id 27so4367301bwz.21
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2009 05:47:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <755510.33826.qm@web52905.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2009 at 05:35:40AM -0800, Chris Rankin wrote:
> --- On Tue, 8/12/09, Jarek Poplawski <jarkao2@gmail.com> wrote:
> > Is it the same .config?
> 
> Similar, but no. I'll attach the .config to the bug tonight.

...And a diff to Fedora's .config, plus if possible try if this
difference could matter.

Jarek P.
