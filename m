From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK PATCH] 2.4 SCTP updates
Date: Fri, 13 Feb 2004 21:54:03 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040213215403.23894e36.davem@redhat.com>
References: <Pine.LNX.4.58.0402131540330.2339@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0402131540330.2339@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 13 Feb 2004 16:07:29 -0800 (PST)
Sridhar Samudrala <sri@us.ibm.com> wrote:

> Please do a
> 	bk pull http://linux-lksctp.bkbits.net/lksctp-2.4.work
> to get the following udpates to SCTP on top fo linux 2.4.25-rc2
> 
> These set of csets bring 2.4 in sync with 2.6 lksctp.

Pulled, thanks for following up on this for me.

Please remember that if you make the suggested modification to ssnmap
allocation, that the 2.4.x tree will need it as well.  In fact, in general,
please try to keep these two trees in sync now that you've done the hard
part :-)
