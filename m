From: "David S. Miller" <davem@redhat.com>
Subject: Re: network delay simulation
Date: Wed, 17 Mar 2004 09:51:07 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040317095107.60728e4e.davem@redhat.com>
References: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
	<20040316174134.2f1da12a.davem@redhat.com>
	<1079539766.1034.99.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1079539766.1034.99.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 17 Mar 2004 11:09:26 -0500
jamal <hadi@cyberus.ca> wrote:

> A simple algorithm is random().

Yes, but you want to weight it just a bit.  Userland could use random()
to generate the bit-stream in fact :)
