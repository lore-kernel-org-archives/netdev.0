From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/2 net-next] Drivers: hv: vmbus: Export the
 vmbus_sendpacket_pagebuffer_ctl()
Date: Tue, 10 Mar 2015 19:25:49 +0100
Message-ID: <20150310182549.GB8040@kroah.com>
References: <1426013383-2853-1-git-send-email-kys@microsoft.com>
 <1426013404-2892-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426013404-2892-1-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 10, 2015 at 11:50:03AM -0700, K. Y. Srinivasan wrote:
> Export the vmbus_sendpacket_pagebuffer_ctl() interface. This interface
> will be used in the netvsc driver to optimize signalling the host.
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
