From: "David S. Miller" <davem@redhat.com>
Subject: Re: networking bugs and bugme.osdl.org
Date: Fri, 27 Jun 2003 15:19:06 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030627.151906.102571486.davem@redhat.com>
References: <3EFCBD12.3070101@candelatech.com>
	<20030627.145456.115915594.davem@redhat.com>
	<3EFCC1EB.2070904@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davidel@xmailserver.org, mbligh@aracnet.com, linux-kernel@vger.kernel.org,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <3EFCC1EB.2070904@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ben Greear <greearb@candelatech.com>
   Date: Fri, 27 Jun 2003 15:15:07 -0700

   Forcing people to continue to retransmit the same report just pisses
   people off, and in the end will get you less useful reports than if
   you had flagged the report as 'please-gimme-more-info'.

And this is different from patch submission in what way?

   Perhaps, but it's also possible that you are being a stubborn SOB
   because you fear change :)
   
Absolutely not, in fact I'm daily looking for ways to change how
I work with people who help me so that I scale better.  And I know
for sure that a bug datamase with shit that accumulates in it
that _REQUIRES_ me to do something about it to make it go away
does not help me scale.

Bugme was an absolute burdon for me.

For something to scale, it must continute to operate just as
efficiently if I were to go away for a few weeks.  The lists have that
quality, the bug database with owner does not.
