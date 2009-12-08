From: Chris Rankin <rankincj@yahoo.com>
Subject: Re: [Bugme-new] [Bug 14749] New: Kernel locks up after a few minutes of heavy surfing
Date: Tue, 8 Dec 2009 05:39:28 -0800 (PST)
Message-ID: <219482.3038.qm@web52901.mail.re2.yahoo.com>
References: <20091208120021.GA24223@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, stable@kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52901.mail.re2.yahoo.com ([206.190.49.11]:39451 "HELO
	web52901.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754809AbZLHNjV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 08:39:21 -0500
In-Reply-To: <20091208120021.GA24223@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--- On Tue, 8/12/09, Neil Horman <nhorman@tuxdriver.com> wrote:
> 30 minutes isn't too long to wait for an error to appear, I think.

Except it's a very "busy" waiting process with me actively surfing the web. I can't automate that. I'm still not entirely sure what the trigger condition is.

Chris


      
