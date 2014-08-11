From: James Smart <james.smart@emulex.com>
Subject: Re: [PATCH net-next 2/2] random32: do not feed jiffies as seed from
 lpfc driver
Date: Mon, 11 Aug 2014 14:38:27 -0400
Message-ID: <53E90DA3.2040907@emulex.com>
References: <1406837317-13648-1-git-send-email-dborkman@redhat.com> <282a2dc3-6381-42d6-ac34-81ceb56f1534@CMEXHTCAS2.ad.emulex.com> <20140811181841.GA29747@infradead.org>
Reply-To: <james.smart@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>,
	James Bottomley <JBottomley@Parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20140811181841.GA29747@infradead.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

yep. I'll do so.

-- james s


On 8/11/2014 2:18 PM, Christoph Hellwig wrote:
> On Mon, Aug 11, 2014 at 01:07:15PM -0400, James Smart wrote:
>> Acked-by:  James Smart  <james.smart@emulex.com>
> Can you jsut queue this up (and the pci fix as well) together with
> anything else you have pending for 3.18?
>
> I'd really like to move towards a model where maintainers of driver
> collect everything for their area to spread work a bit better.
>
>
>

