From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK PATCH] 2.4 SCTP updates.
Date: Fri, 27 Feb 2004 13:38:07 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040227133807.453e8d4b.davem@redhat.com>
References: <Pine.LNX.4.58.0402271216200.12389@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0402271216200.12389@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 27 Feb 2004 12:31:18 -0800 (PST)
Sridhar Samudrala <sri@us.ibm.com> wrote:

> Thanks for fixing the MSECS_TO_JIFFIES warning.

No problem.  Maybe we want to rename some of those other macros
to have SCTP_ prefixes too?

> Here are a few updates to SCTP on top of the latest 2.4 BK tree. It includes
> fixes to NIP6 macro compile error, incorrect packed attribute usage and
> a bug with sinit_max_init_timeo behavior.
> 
> please do a
> 	bk pull http://linux-lksctp.bkbits.net/lksctp-2.4.work

Pulled, thanks.
