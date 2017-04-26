From: Logan Gunthorpe <logang@deltatee.com>
Subject: Re: [PATCH v2 01/21] scatterlist: Introduce sg_map helper functions
Date: Wed, 26 Apr 2017 17:30:47 -0600
Message-ID: <5958e5fc-e73f-1457-781f-05378fa1fd46@deltatee.com>
References: <1493144468-22493-1-git-send-email-logang@deltatee.com>
 <1493144468-22493-2-git-send-email-logang@deltatee.com>
 <5dfc5bf5-482c-b5bb-029c-7cee80925f37@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <axboe@kernel.dk>,
 "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
 "Martin K. Petersen" <martin.petersen@oracle.com>,
 Matthew Wilcox <mawilcox@microsoft.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Stephen Bates <sbates@raithlin.com>,
 Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>,
 Dan Williams <dan.j.williams@intel.com>
To: =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>,
 linux-kernel@vger.kernel.org, linux-crypto@vger.kernel.org,
 linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org,
 intel-gfx@lists.freedesktop.org, linux-raid@vger.kernel.org,
 linux-mmc@vger.kernel.org, linux-nvdimm@lists.01.org,
 linux-scsi@vger.kernel.org, open-iscsi@googlegroups.com,
 megaraidlinux.pdl@broadcom.com, sparmaintainer@unisys.com,
 devel@driverdev.osuosl.org, target-devel@vger.kernel.org,
 netdev@vger.kernel.org, linux-rdma@vger.kernel.org, dm-devel@redhat.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <5dfc5bf5-482c-b5bb-029c-7cee80925f37@amd.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



On 26/04/17 02:59 AM,   wrote:
> Good to know that somebody is working on this. Those problems troubled
> us as well.

Thanks Christian. It's a daunting problem and a there's a lot of work to
do before we will ever be where we need to be so any help, even an ack,
is greatly appreciated.

Logan
