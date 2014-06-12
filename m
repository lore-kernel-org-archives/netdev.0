From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH] vhost-scsi: don't open-code kvfree
Date: Thu, 12 Jun 2014 10:59:03 -0700
Message-ID: <1402595943.18202.0.camel@haakon3.risingtidesystems.com>
References: <1402588896-25446-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1402588896-25446-1-git-send-email-mst@redhat.com>
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

On Thu, 2014-06-12 at 19:02 +0300, Michael S. Tsirkin wrote:
> Now that we have kvfree, use it in vhost-scsi instead of
> the open-coded version.
> 
> Cc: Nicholas Bellinger <nab@linux-iscsi.org>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
> 
> I have this queued for -rc2.
> Nicholas could you review ack pls?


Reviewed-by + Acked-by: Nicholas Bellinger <nab@linux-iscsi.org>

Thanks MST!
