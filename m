From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Wed, 09 Oct 2002 16:14:14 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021009.161414.63434223.davem@redhat.com>
References: <20021009170018.H29133@edinburgh.cisco.com>
	<uwuor9tg7.wl@sfc.wide.ad.jp>
	<20021009234421.J29133@edinburgh.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sekiya@sfc.wide.ad.jp, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dfawcus@cisco.com
In-Reply-To: <20021009234421.J29133@edinburgh.cisco.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I think the change was made because some TAHI test
failed without it, USAGI people is this right?

Most of USAGI changes are of this nature. :-)
