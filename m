From: David Teigland <teigland@redhat.com>
Subject: Re: [PATCH 17/23] dlm: use per-attribute show and
 store methods
Date: Mon, 28 Sep 2015 09:49:49 -0500
Message-ID: <20150928144949.GA30917@redhat.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
	<1443189000-13398-18-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pratyush Anand <pratyush.anand@gmail.com>, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, Felipe Balbi <balbi@ti.com>,
        cluster-devel@redhat.com, target-devel@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
        ocfs2-devel@oss.oracle.com
To: Christoph Hellwig <hch@lst.de>
Return-path: <cluster-devel-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <1443189000-13398-18-git-send-email-hch@lst.de>
List-Unsubscribe: <https://www.redhat.com/mailman/options/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Fri, Sep 25, 2015 at 06:49:54AM -0700, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/dlm/config.c | 288 +++++++++++++++-----------------------------------------
>  1 file changed, 74 insertions(+), 214 deletions(-)

Looks good to me.
Dave
