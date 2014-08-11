From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH net-next 2/2] random32: do not feed jiffies as seed from
 lpfc driver
Date: Mon, 11 Aug 2014 11:18:41 -0700
Message-ID: <20140811181841.GA29747@infradead.org>
References: <1406837317-13648-1-git-send-email-dborkman@redhat.com>
 <282a2dc3-6381-42d6-ac34-81ceb56f1534@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, James Bottomley <JBottomley@Parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>
To: James Smart <james.smart@emulex.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <282a2dc3-6381-42d6-ac34-81ceb56f1534@CMEXHTCAS2.ad.emulex.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 11, 2014 at 01:07:15PM -0400, James Smart wrote:
> Acked-by:  James Smart  <james.smart@emulex.com>

Can you jsut queue this up (and the pci fix as well) together with
anything else you have pending for 3.18?

I'd really like to move towards a model where maintainers of driver
collect everything for their area to spread work a bit better.

