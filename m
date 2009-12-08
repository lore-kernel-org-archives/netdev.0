From: Chris Rankin <rankincj@yahoo.com>
Subject: Re: [Bugme-new] [Bug 14749] New: Kernel locks up after a few minutes of heavy surfing
Date: Tue, 8 Dec 2009 01:17:28 -0800 (PST)
Message-ID: <891805.85472.qm@web52908.mail.re2.yahoo.com>
References: <4B1DC202.20607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, stable@kernel.org,
	Neil Horman <nhorman@tuxdriver.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52908.mail.re2.yahoo.com ([206.190.49.18]:47550 "HELO
	web52908.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752187AbZLHJRW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 04:17:22 -0500
In-Reply-To: <4B1DC202.20607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One other thing: this is an SMP machine with 2 physical hyper-threaded CPUs in. And all its IP traffic is routed through a UP 200MHz Pentium MMX machine that is also running 2.6.31.6 via an e100 card.

The Pentium MMX machine has been rock-solid so far.

Cheers,
Chris


      
