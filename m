From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (resend) fix sock_raw behaviour
Date: Fri, 10 Oct 2003 04:16:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031010041633.3274c654.davem@redhat.com>
References: <20031008235150.A207@jeroen.pe1rxq.ampr.org>
	<20031009235338.7335b635.davem@redhat.com>
	<20031010132157.A4188@jeroen.pe1rxq.ampr.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com, ralf@linux-mips.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeroen Vreeken <pe1rxq@amsat.org>
In-Reply-To: <20031010132157.A4188@jeroen.pe1rxq.ampr.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 10 Oct 2003 13:21:57 +0200
Jeroen Vreeken <pe1rxq@amsat.org> wrote:

> On 2003.10.10 08:53:38 +0200 David S. Miller wrote:
> > While we're talking about this, who is going to maintain AX25
> > in 2.6.x?  I don't want to be taking bug fixes and other changes
> > to AX25 from random people, I'd like to have a single contact
> > that will review the AX25 patches from other people and then
> > forward them off to me.
> 
> The official maintainer for ax25 and netrom is Ralf Baechle. but he seems
> to have some problems fitting it into his schedule....

If that's the case why don't we have someone like you take
care of things until he is less busy?
