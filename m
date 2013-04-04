From: Joe Perches <joe@perches.com>
Subject: Re: [Suggestion] ISDN: isdnloop:  C grammar issue,  '}' miss match
 'if' and 'switch' statement.
Date: Thu, 04 Apr 2013 07:42:19 -0700
Message-ID: <1365086539.5248.7.camel@joe-AO722>
References: <515C303B.1040304@asianux.com>
	 <20130403140823.GB3401@unicorn.suse.cz> <515D4253.5040205@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Michal Kubecek <mkubecek@suse.cz>, fengguang.wu@intel.com,
	isdn@linux-pingi.de,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:36899 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761895Ab3DDOmU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Apr 2013 10:42:20 -0400
In-Reply-To: <515D4253.5040205@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-04 at 17:05 +0800, Chen Gang wrote:

> > As far as I can see, this rather comes from
> > commit 475be4d85a274d0961593db41cf85689db1d583c
[]
> Joe Perches only beautified the code, not change the contents.

I modified alll those files using emacs
	c-indent-line-or-region
which does a decent job in most cases
but emacs is easily confused.
