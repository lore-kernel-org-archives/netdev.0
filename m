From: "David S. Miller" <davem@redhat.com>
Subject: Re: [janitor] get_stats: collapse conditionals
Date: Sun, 25 Jan 2004 11:10:14 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040125.111014.68044194.davem@redhat.com>
References: <20040124221928.16f4c708.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rddunlap@osdl.org
In-Reply-To: <20040124221928.16f4c708.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: "Randy.Dunlap" <rddunlap@osdl.org>
   Date: Sat, 24 Jan 2004 22:19:28 -0800

   Please apply to 2.6.current.
 ...   
   From: Domen Puncer <domen@coderock.org>

Applied, although I changed

	}
	else

to

	} else
