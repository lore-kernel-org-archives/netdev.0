From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Wed, 09 Oct 2002 16:24:38 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021009.162438.82081593.davem@redhat.com>
References: <20021009234421.J29133@edinburgh.cisco.com>
	<20021009.161414.63434223.davem@redhat.com>
	<20021010002902.A3803@edi-view1.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sekiya@sfc.wide.ad.jp, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dfawcus@cisco.com
In-Reply-To: <20021010002902.A3803@edi-view1.cisco.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Derek Fawcus <dfawcus@cisco.com>
   Date: Thu, 10 Oct 2002 00:29:02 +0100

   There are areas where the TAHI tests expect a certain behaviour
   when more than one behaviour is acceptable.

Great, that's what I was trying to find out.

Now I just need to know if this link-local prefix case
is one such issue. :-)
