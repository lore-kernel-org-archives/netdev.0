From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v4 13/25] virtio_console: enable VQs early
Date: Mon, 20 Oct 2014 15:44:53 +0100
Message-ID: <20141020144453.GD18561@casper.infradead.org>
References: <1413114332-626-1-git-send-email-mst-v4@redhat.com>
 <1413114332-626-14-git-send-email-mst-v4@redhat.com>
 <20141020120750.GA18561@casper.infradead.org>
 <20141020144223.5655dcbc.cornelia.huck@de.ibm.com>
 <20141020133555.GA27111@redhat.com>
 <20141020140410.GA10994@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: wlinux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	virtualization@lists.linux-foundation.org,
	linux-scsi@vger.kernel.org, linux-s390@vger.kernel.org,
	v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	kvm@vger.kernel.org, Amit Shah <amit.shah@redhat.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: "Michael S. Tsirkin" <mst@redhat.com>,
	Cornelia Huck <cornelia.huck@de.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141020140410.GA10994@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/20/14 at 05:04pm, Michael S. Tsirkin wrote:
> Sure enough, this helps:
> 
> Tested-by: Michael S. Tsirkin <mst@redhat.com>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Pls repost as a top-level patch.

Thanks for fixing this so promptly.
