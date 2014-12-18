From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: pull-request: mac80211 2014-12-18
Date: Thu, 18 Dec 2014 21:54:29 +0100
Message-ID: <1418936069.10864.1.camel@sipsolutions.net>
References: <1418911822.6134.13.camel@sipsolutions.net>
	 <20141218.153520.221364366280641527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:43377 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751225AbaLRVNs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Dec 2014 16:13:48 -0500
In-Reply-To: <20141218.153520.221364366280641527.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-12-18 at 15:35 -0500, David Miller wrote:

> 1) Don't put things into a merge commit, I take the text from your
>    pull request email and that becomes the merge commit contents.
>    Put it in your pull request email.

Hmm, ok - not sure I fully understand. I don't think I created a merge
commit, so did you mean the tag? I thought a (signed) tag with contents
was now the preferred way to send pull requests, but I can also send a
signed email without a tag for you to merge a branch? Or would you
prefer a signed tag but empty (is that even possible?) with the text in
the email?

> 2) I want every pull request I get at least CC:'d to netdev.

Ok, sure.

Thanks,
johannes
