From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TCP's reaction to soft errors
Date: Fri, 1 Oct 2004 15:13:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001151325.1bf112a5.davem@davemloft.net>
References: <4.3.2.7.2.20040915112853.00cf9980@mail.daleclick.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Fernando Gont <fernando@gont.com.ar>
In-Reply-To: <4.3.2.7.2.20040915112853.00cf9980@mail.daleclick.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004 11:44:14 -0300
Fernando Gont <fernando@gont.com.ar> wrote:

> The draft proposes to change TCP's reaction to soft errors so that 
> connections that are in the SYN-SENT or SYN-RECEIVED states are aborted 
> upon receipt of an ICMP error message that indicates a soft error.

I have verified that Linux behaves in a way compliant to this
proposal.  No changes are necessary.
