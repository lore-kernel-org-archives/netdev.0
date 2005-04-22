From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.12-rc2 0/11] tg3: Add complete support for 5752
Date: Thu, 21 Apr 2005 17:15:33 -0700
Message-ID: <20050421171533.6296be09.davem@davemloft.net>
References: <04132005193843.8300@laptop>
	<1113806551.6504.11.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <1113806551.6504.11.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 17 Apr 2005 23:42:31 -0700
"Michael Chan" <mchan@broadcom.com> wrote:

> These patches should be applied on top of John Linville's patches posted
> a few days ago.
> 
> The last 2 patches are MSI patches for 5751 C0 and 5752. They are very
> similar to the MSI patches posted a few weeks ago. I've modified the MSI
> test patch to display a warning message to ask the user to report the
> failure if the MSI test fails. If Jeff still objects to this, then just
> skip patch 11 but apply patch 10 which enables MSI on the latest chips.

I decided to apply everything, even the MSI test stuff, it seems
perfectly reasonable to me.

I'll work on backporting all of this 5752 stuff to 2.4.x later today.
