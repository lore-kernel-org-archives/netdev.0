From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] packet delay scheduler
Date: Thu, 18 Mar 2004 20:53:46 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040318205346.3fd7829d.davem@redhat.com>
References: <20040316151058.3cc2fa28@dell_ss3.pdx.osdl.net>
	<20040316174134.2f1da12a.davem@redhat.com>
	<20040318120451.1c9ee286@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lartc@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040318120451.1c9ee286@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Mar 2004 12:04:51 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Okay, here is a very simple QOS scheduler that delays packets for 2.6.
> It is good for testing, and might be useful for people who want to put
> some class of traffic into a "penalty box".

I'm happy with this and added it to my 2.6.x tree.

Could you cook up a 2.4.x variant for me?  Thanks.
