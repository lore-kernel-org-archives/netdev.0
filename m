From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 0/8] textsearch: case insensitive pattern matching for netfilter
Date: Tue, 24 Jun 2008 16:00:04 +0200
Message-ID: <20080624140004.GI20815@postel.suug.ch>
References: <b25c3fa70806210054o74a46068ifa3b396662080265@mail.gmail.com> <20080623232756.GH20815@postel.suug.ch> <b25c3fa70806231825q21144461jdcc20cc77aff8c80@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b25c3fa70806231825q21144461jdcc20cc77aff8c80@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Joonwoo Park <joonwpark81@gmail.com> 2008-06-23 18:25
> 2008/6/23 Thomas Graf <tgraf@suug.ch>:
> > It should be noted that this may slow down the algorithms noticeable for
> > very large strings such as skb data buffers.
> >
> 
> Do you mean a note by commenting on the code? or any message to user?

It would be a useful comment in the documentation as users may not
expect it.
