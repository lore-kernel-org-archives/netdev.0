From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next 0/5] refine virtio-net XDP
Date: Tue, 18 Jul 2017 21:47:01 +0300
Message-ID: <20170718214645-mutt-send-email-mst@kernel.org>
References: <1500295441-19339-1-git-send-email-jasowang@redhat.com>
	<20170718.112442.705495974245565173.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20170718.112442.705495974245565173.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 18, 2017 at 11:24:42AM -0700, David Miller wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Mon, 17 Jul 2017 20:43:56 +0800
> 
> > This series brings two optimizations for virtio-net XDP:
> > 
> > - avoid reset during XDP set
> > - turn off offloads on demand
> > 
> > Please review.
> 
> Michael, please review Jason's changes.
> 
> Thanks.

Doing that, thanks for the reminder.

-- 
MST
