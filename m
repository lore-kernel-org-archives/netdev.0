From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (12/17) irda -- size_t for send/recvmsg
Date: Thu, 8 Jan 2004 15:36:17 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040108153617.58a75a75.davem@redhat.com>
References: <20040109140317.0a8a30a8@linux.local>
	<20040108225657.GB22438@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jt@bougret.hpl.hp.com, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jt@hpl.hp.com
In-Reply-To: <20040108225657.GB22438@bougret.hpl.hp.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 8 Jan 2004 14:56:57 -0800
Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:

> On Fri, Jan 09, 2004 at 02:03:17PM -0800, Stephen Hemminger wrote:
> > Convert IRDA to unsigned length for send/recv msg.
> 
> 	Ok, I've added that on my web page and will remind Dave if he
> doesn't pick it up.

Don't worry, I'll queue all of these up for 2.6.2, it's too late for 2.6.1 at this
point.
