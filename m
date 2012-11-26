From: Dmitry Torokhov <dtor@vmware.com>
Subject: Re: [Pv-drivers] [PATCH 203/493] net: remove use of __devinit
Date: Mon, 26 Nov 2012 09:38:46 -0800
Message-ID: <20121126173846.GD11127@dtor-ws.eng.vmware.com>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
	<1353349642-3677-203-git-send-email-wfp5p@virginia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, "VMware, Inc." <pv-drivers@vmware.com>,
	gregkh@linuxfoundation.org, Francois Romieu <romieu@fr.zoreil.com>,
	virtualization@lists.linux-foundation.org, linux-hippi@sunsite.dk,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev@vger.kernel.org, Krzysztof Halasa <khc@pm.waw.pl>
To: Bill Pemberton <wfp5p@virginia.edu>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1353349642-3677-203-git-send-email-wfp5p@virginia.edu>
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

On Mon, Nov 19, 2012 at 01:22:32PM -0500, Bill Pemberton wrote:
> CONFIG_HOTPLUG is going away as an option so __devinit is no longer
> needed.

...

>  drivers/net/vmxnet3/vmxnet3_drv.c  |  2 +-

For VMXNET3:

Acked-by: Dmitry Torokhov <dtor@vmware.com>

Thanks,
Dmitry
