From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH 0/8] textsearch: case insensitive pattern matching for netfilter
Date: Sat, 21 Jun 2008 00:54:55 -0700
Message-ID: <b25c3fa70806210054o74a46068ifa3b396662080265@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, "Thomas Graf" <tgraf@suug.ch>,
	"Pablo Neira Ayuso" <pablo@netfilter.org>,
	"David Miller" <davem@davemloft.net>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

This patchset aim at supporting case insensitive text search for netfilter
string extension.
It contains fixing of Boyer-Moore algorithm and Knuth-Morris-Pratt algorithm.
Also this includes bug fixing of Boyer-Moore algorithm.

Please consider applying this patchset.

Thanks,
Joonwoo
