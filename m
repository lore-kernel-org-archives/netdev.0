From: Chris Rankin <rankincj@yahoo.com>
Subject: Re: [Bugme-new] [Bug 14749] New: Kernel locks up after a few minutes of heavy surfing
Date: Mon, 7 Dec 2009 16:38:26 -0800 (PST)
Message-ID: <797041.38013.qm@web52902.mail.re2.yahoo.com>
References: <20091207135342.6fb07264.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: bugme-daemon@bugzilla.kernel.org, stable@kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web52902.mail.re2.yahoo.com ([206.190.49.12]:37564 "HELO
	web52902.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965161AbZLHAiU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2009 19:38:20 -0500
In-Reply-To: <20091207135342.6fb07264.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One other point that seems worth mentioning: Fedora's 2.6.31.6-162.fc12.i686 kernel does *not* seem to have this problem, and neither did 2.6.31.6-145.fc12.i686 before it. (Fedora kernels have had KMS problems, but nothing that has stopped SysRq from working.)

Cheers,
Chris


      
