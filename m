From: "David S. Miller" <davem@redhat.com>
Subject: Re: ip addr flush hangs
Date: Tue, 9 Mar 2004 15:29:32 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040309152932.36a42997.davem@redhat.com>
References: <20040309144824.GD14419@suse.de>
	<20040309150730.GE14419@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040309150730.GE14419@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 9 Mar 2004 16:07:30 +0100
Olaf Kirch <okir@suse.de> wrote:

> The attached patch disables reporting of multicast and anycast
> addresses in inet6_dump_ifaddr

Applied, except I changed it to just remove the code entirely instead
of commenting it out.
