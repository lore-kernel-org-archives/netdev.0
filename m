From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK PATCH] 2.4 SCTP updates.
Date: Sat, 28 Feb 2004 15:49:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040228154959.03ddfdde.davem@redhat.com>
References: <Pine.LNX.4.58.0402271216200.12389@localhost.localdomain>
	<20040227133807.453e8d4b.davem@redhat.com>
	<Pine.LNX.4.58.0402271435080.13107@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0402271435080.13107@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 27 Feb 2004 14:52:08 -0800 (PST)
Sridhar Samudrala <sri@us.ibm.com> wrote:

> Are you referring to JIFFIES_TO_MSECS?

Yes.

> Do you see any other macros that need
> renaming? I think rest of the macros do have SCTP_ prefix.

Not offhand, no.

> As Jeff said, may be we should make them generic?
> Is include/linux/time.h a good place?

Possibly, have a chat with Jeff on this so he can consolidate his
uses as well.
