From: Dmitry Torokhov <dtor@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 471/493] net: remove use of __devexit
Date: Mon, 26 Nov 2012 09:39:15 -0800
Message-ID: <20121126173915.GE11127@dtor-ws.eng.vmware.com>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
	<1353349642-3677-471-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby@gmail.com>, "Michael S. Tsirkin" <mst@redhat.com>,
	"VMware, Inc." <pv-drivers@vmware.com>,
	virtualization@lists.linux-foundation.org,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	Christian Lamparter <chunkeey@googlemail.com>,
	Hin-Tak Leung <htl10@users.sourceforge.net>,
	Luciano Coelho <coelho@ti.com>, Stefano Brivio <stefano.brivio@polimi.it>,
	libertas-dev@lists.infradead.org, Dan Williams <dcbw@redhat.com>,
	ath5k-devel@lists.ath5k.org, "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	linux-hippi@sunsite.dk, Nick Kossifidis <mickflemm@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Herton Ronaldo Krzesinski <herton@canonical.com>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	b43-dev@lists.infradead.org, Samuel Ortiz <samuel@sortiz.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-can@vger.kernel.org, xen-devel@lists.xensource.com,
	Marc K
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1353349642-3677-471-git-send-email-wfp5p@virginia.edu>
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

On Mon, Nov 19, 2012 at 01:27:00PM -0500, Bill Pemberton wrote:
> CONFIG_HOTPLUG is going away as an option so __devexit is no
> longer needed.

...

>  drivers/net/vmxnet3/vmxnet3_drv.c             |  2 +-

For VMXNET3:

Acked-by: Dmitry Torokhov <dtor@vmware.com>

Thanks,
Dmitry
