From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] netem --
Date: Wed, 21 Jul 2004 13:45:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040721134557.7c0a4a8d.davem@redhat.com>
References: <20040712101500.4a0babd3@dell_ss3.pdx.osdl.net>
	<20040713151959.2470a211@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040713151959.2470a211@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


All 3 netem patches applied to 2.6.x, thanks Stephen.

The 2.4.x copy of this thing is falling behind the 2.6.x
code.  By diffing the two you can see what is missing,
the randomization jitter feature is the biggest part.
