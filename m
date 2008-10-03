From: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Subject: Re: [PATCH 00/32] Swap over NFS - v19
Date: Fri, 3 Oct 2008 14:17:31 -0300
Message-ID: <20081003141731.37bda8f3@doriath.conectiva>
References: <20081002130504.927878499@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Neil Brown <neilb@suse.de>, David Miller <davem@davemloft.net>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perninha.conectiva.com.br ([200.140.247.100]:37268 "EHLO
	perninha.conectiva.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753203AbYJCRRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 13:17:11 -0400
In-Reply-To: <20081002130504.927878499@chello.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, 02 Oct 2008 15:05:04 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> escreveu:

| Patches are against: v2.6.27-rc5-mm1
| 
| This release features more comments and (hopefully) better Changelogs.
| Also the netns stuff got sorted and ipv6 will now build and not oops
| on boot ;-)
| 
| The first 4 patches are cleanups and can go in if the respective maintainers
| agree.
| 
| The code is lightly tested but seems to work on my default config.
| 
| Let's get this ball rolling...

 What's the best way to test this? Create a swap in a NFS mount
point and stress it?

-- 
Luiz Fernando N. Capitulino
