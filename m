From: Olaf Hering <olh@suse.de>
Subject: Re: [PATCH] e1000, errata 2{3,
	4} - possible EEH or memory corruption when DMA crosses a 64k
	boundary
Date: Tue, 1 Feb 2005 20:40:10 +0100
Message-ID: <20050201194010.GA7892@suse.de>
References: <468F3FDA28AA87429AD807992E22D07E041A065B@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@oss.sgi.com, "Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg,  Jesse" <jesse.brandeburg@intel.com>,
	linuxppc64-dev@ozlabs.org
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Content-Disposition: inline
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E041A065B@orsmsx408>
List-Unsubscribe: <https://ozlabs.org/cgi-bin/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/cgi-bin/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

 On Tue, Feb 01, Venkatesan, Ganesh wrote:

> In any case, this fix is required in e1000. It is *not* in the latest
> driver that is released but *is* in the driver that is lined up for
> release in a couple of weeks.

Thats good enough, just that things dont get lost. There are probably a
few separate patches for each problem found.
We are still in the process of sorting out our +2k patch mess.
