From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: e1000e fails probe
Date: Mon, 10 May 2010 22:43:08 -0600
Message-ID: <20100510224308.4334fd11@redhat.com>
References: <20100510185018.3478bcae@redhat.com>
	<8DD2590731AB5D4C9DBF71A877482A90010D1DE754@orsmsx509.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	zaitcev@redhat.com
To: "Allan, Bruce W" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28395 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751561Ab0EKEnF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 May 2010 00:43:05 -0400
In-Reply-To: <8DD2590731AB5D4C9DBF71A877482A90010D1DE754@orsmsx509.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 May 2010 18:33:56 -0700
"Allan, Bruce W" <bruce.w.allan@intel.com> wrote:

> Would you be able to try a patch that is already in DaveM's net-next-2.6 tree?  If so, it is http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=627c8a041f7aaaea93c766f69bd61d952a277586

I was too quick to claim victory here. I did an rmmod+insmod,
it worked. Then I rebooted and it didn't. Weird...

-- Pete
