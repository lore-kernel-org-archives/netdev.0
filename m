From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 1/8] Create ipv4_is_<type>(__be32 addr)
 functions
Date: Sun, 16 Dec 2007 13:42:58 -0800 (PST)
Message-ID: <20071216.134258.150452499.davem@davemloft.net>
References: <1197589141-7020-1-git-send-email-joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761629AbXLPVnV@vger.kernel.org>
In-Reply-To: <1197589141-7020-1-git-send-email-joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 13 Dec 2007 15:38:54 -0800

> Change IPV4 specific macros LOOPBACK MULTICAST LOCAL_MCAST BADCLASS and ZERONET
> macros to inline functions ipv4_is_<type>(__be32 addr)
> 
> Adds type safety and arguably some readability.
> 
> Changes since last submission:
> 
> Removed ipv4_addr_octets function
> Used hex constants
> Converted recently added rfc3330 macros
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
