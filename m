From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] TCP congestion infrastructure
Date: Mon, 9 May 2005 16:22:14 -0700
Message-ID: <20050509162214.0a8c9ceb@dxpl.pdx.osdl.net>
References: <20050506173729.20140.93205.37072@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Baruch Even <baruch@ev-en.org>,
        Douglas Leith
 <doug.leith@nuim.ie>,
        "David S.Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: <20050506173729.20140.93205.37072@galon.ev-en.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I rebased the H-TCP patches on my current work and 2.6.12-rc4 and put them in
	http://developer.osdl.org/shemminger/patches/2.6.12-rc4-tcp/

Includes infrastructure and all the current variants: BIC, Westwood, Vegas
    plus  H-TCP, Hybla
