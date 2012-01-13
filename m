From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: Re: [PATCH] rds_rdma: don't assume infiniband device is PCI
Date: Fri, 13 Jan 2012 16:17:06 -0200
Message-ID: <20120113181706.GA3904@oc1711230544.ibm.com>
References: <1325714596-4655-1-git-send-email-cascardo@linux.vnet.ibm.com>
 <CAL1RGDWOitrKp31RuWLCV3ifUa=CKvZ2qZaRQJMcxdU6_eubww@mail.gmail.com>
 <CAL1RGDVEqr9XzzcpG6wK49e209JtrhXGayFa5Qnz_NziLinR-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: venkat.x.venkatsubra@oracle.com, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dledford@redhat.com, Jes.Sorensen@redhat.com,
	rds-devel@oss.oracle.com
To: Roland Dreier <roland@purestorage.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAL1RGDVEqr9XzzcpG6wK49e209JtrhXGayFa5Qnz_NziLinR-g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 06, 2012 at 09:49:36AM -0800, Roland Dreier wrote:
> On Fri, Jan 6, 2012 at 9:47 AM, Roland Dreier <roland@purestorage.com> wrote:
> > Looks great to me:
> 
> And BTW if Oracle has some non-published work they should probably just
> rebase it on top of this fix.  We should merge this rather than shipping a
> kernel with an obvious know crash like this.
> 
>  - R.
> 

Hi, Roland.

Sorry that I didn't include you. Should I include the infiniband users
under net/ in the files that Infiniband maintainers take care of?

David,

Is this going through your tree? In patchwork, its state is "Not
Applicable".

Thanks.
Cascardo.
