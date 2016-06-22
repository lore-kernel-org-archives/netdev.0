From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: rstpd implementation
Date: Wed, 22 Jun 2016 11:12:12 -0700
Message-ID: <20160622111212.249aef89@xeon-e3>
References: <576A8873.50809@gmx.ch>
	<874m8lqfsb.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Phil <pme.neratec@gmx.ch>, linux-kernel@vger.kernel.org,
	<netdev@vger.kernel.org>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <874m8lqfsb.fsf@x220.int.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 22 Jun 2016 12:44:52 -0500
ebiederm@xmission.com (Eric W. Biederman) wrote:

> Phil <pme.neratec@gmx.ch> writes:
> 
> > Hi,
> >
> > When looking for an RSTP daemon I found Stephen Hemminger's
> > git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/rstp.git
> > <https://kernel.googlesource.com/pub/scm/linux/kernel/git/shemminger/rstp#zSoyz>
> > with it's last commit from October 2011.
> >
> > Is this implementation still in good use by anybody - or has it been
> > replaced/superseded by another implementation?
> 
> I don't know and when you get into user space daemons they aren't much
> talked about on the kernel lists.  That said you will likely fair better
> on the netdev list (cc'd).
> 
> Eric

The current one I recommend is the MSTPd done by Cumulus
 https://sourceforge.net/p/mstpd/wiki/Home/
But like all projects they could use help
