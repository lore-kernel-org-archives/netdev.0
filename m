From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] UDP/IPv6 multicasting
Date: Mon, 17 Nov 2003 12:41:04 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031117124104.570e1c72.davem@redhat.com>
References: <OF974281CA.F4EE30F2-ON88256DDE.007F34F9@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF974281CA.F4EE30F2-ON88256DDE.007F34F9@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 14 Nov 2003 16:11:50 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

>       Below is a patch to fix a problem reported by Brian Buesker. When
> binding to
> two different multicast addresses on the same UDP port, a copy sent to
> either multicast
> address is delivered to both.

Thanks a lot David, I will review and probably apply this later
on today.

2.4.x has identical code in this spot so I'll put the fix there
as well and queue it up for 2.4.24-pre1.

Thanks again.
