From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 2/9] tproxy: added const specifiers to udp lookup functions
Date: Thu, 21 Oct 2010 16:05:27 +0200
Message-ID: <4CC048A7.5040700@trash.net>
References: <20101021104709.5192.31249.stgit@este.odu> <20101021104709.5192.54276.stgit@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>,
	David Miller <davem@davemloft.net>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20101021104709.5192.54276.stgit@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 21.10.2010 12:47, schrieb KOVACS Krisztian:
> The parameters for various UDP lookup functions were non-const, even though
> they could be const. TProxy has some const references and instead of
> downcasting it, I added const specifiers along the path.

Applied, thanks.
