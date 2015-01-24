From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Sat, 24 Jan 2015 13:48:46 +0000
Message-ID: <20150124134846.GB27523@casper.infradead.org>
References: <20150122125246.GA4486@salvia>
 <20150122133713.GA25797@casper.infradead.org>
 <20150122140022.GA5674@salvia>
 <54C11094.2000807@mojatatu.com>
 <20150122151316.GB25797@casper.infradead.org>
 <54C11703.7030702@mojatatu.com>
 <20150122153727.GC25797@casper.infradead.org>
 <20150122164951.GA3417@salvia>
 <20150122174445.GD25797@casper.infradead.org>
 <54C39161.9030300@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	John Fastabend <john.fastabend@gmail.com>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com, Jiri Pirko <jiri@resnulli.us>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:52657 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbbAXNsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jan 2015 08:48:47 -0500
Content-Disposition: inline
In-Reply-To: <54C39161.9030300@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/24/15 at 07:34am, Jamal Hadi Salim wrote:
> They are not the same. The API lowers the barrier immensely; refer to
> my response to John. And we are actually handing it to them.
> 
> From an equivalance perspective:
> Youd have to convince Dave to allow all those TOE vendors to get in
> with their direct hardware APIs (if those guys are still around).

I'm not advocating TOE, not sure why that pops up. I made the point
that various ways already exist for an out of tree driver to expose
a Netlink or other interface which provides direct access to the
hardware and that we can't prevent that.

Anyways, looks like you agree to the general direction the thread has
taken with Jiri's input.
