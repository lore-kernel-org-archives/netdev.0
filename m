From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [trivial] treewide: Add __GFP_NOWARN to k.alloc calls with
 v.alloc fallbacks
Date: Sun, 23 Jun 2013 14:40:51 -0400
Message-ID: <20130623184051.GA13222@thunk.org>
References: <1371669353.2038.45.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Kosina <trivial@kernel.org>,
	Lars Ellenberg <drbd-dev@lists.linbit.com>,
	Hoang-Nam Nguyen <hnguyen@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Roland Dreier <roland@kernel.org>,
	Sean Hefty <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Divy Le Ray <divy@chelsio.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Chris Mason <chris.mason@fusionio.com>,
	Andreas Dilger <adilger.kernel@dilger.ca>,
	Steven Whitehouse <swhiteho@redhat.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>,
	drbd-user@lists.linbit.com, linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-btrfs@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	cluster-devel <cluster-devel@redhat.com>
To: Joe Perches <joe@perches.com>
Return-path: <linux-btrfs-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1371669353.2038.45.camel@joe-AO722>
Sender: linux-btrfs-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 19, 2013 at 12:15:53PM -0700, Joe Perches wrote:
> Don't emit OOM warnings when k.alloc calls fail when
> there there is a v.alloc immediately afterwards.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

For fs/ext4/super.c:

Acked-by: "Theodore Ts'o" <tytso@mit.edu>

					- Ted
