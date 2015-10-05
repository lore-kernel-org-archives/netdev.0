From: Florian Westphal <fw@strlen.de>
Subject: Re: [net-next:master 647/682] fib_semantics.c:undefined reference to
 `__divdi3'
Date: Mon, 5 Oct 2015 23:35:20 +0200
Message-ID: <20151005213520.GA12921@breakpoint.cc>
References: <201510051816.pL2fiACx%fengguang.wu@intel.com>
 <20151005.042638.1280563834697071426.davem@davemloft.net>
 <20151005233158.2c09adce@tyr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Peter =?iso-8859-15?Q?N=F8rlund?= <pch@ordbogen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:55854 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751220AbbJEVfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 17:35:22 -0400
Content-Disposition: inline
In-Reply-To: <20151005233158.2c09adce@tyr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter N=F8rlund <pch@ordbogen.com> wrote:
> What is the proper way to supply fixes for this kind of errors? Shoul=
d
> I submit the original patches again with the bug fixed, or should I
> submit a patch fixing this particular problem?

The latter, relative fix, with 'Fixes: <sha1> ("name of commit") tag'.
