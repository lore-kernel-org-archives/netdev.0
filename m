From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4/2.6] ipvs: improve conn rehashing, other fixes
Date: Tue, 23 Mar 2004 00:40:06 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040323004006.14b2373e.davem@redhat.com>
References: <20040321230703.408d2240.davem@redhat.com>
	<Pine.LNX.4.44.0403230036130.3318-600000@penguin.linux-vs.org>
	<20040322183641.68ecb8a3.davem@redhat.com>
	<Pine.LNX.4.58.0403231027420.1157@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: wensong@linux-vs.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0403231027420.1157@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 23 Mar 2004 10:34:54 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> 	It was the old version. Please, apply everything sent from
> Wensong. The old versions protect only the list which is not needed
> on edit but the new versions from Wensong ensure that the service is
> updated safely while there are no other CPUs using the schedulers.

Sorry, wires got crossed.  Julian/Wensong, could you please resend
that ip_vs_ctl.c locking change under seperate cover then?

Thanks.
