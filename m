From: "Alexey Dobriyan" <adobriyan@gmail.com>
Subject: Re: kernel panic on T60 by e1000 driver
Date: Mon, 18 Sep 2006 13:47:23 +0400
Message-ID: <b6fcc0a0609180247j460811fao651a7883bb4dd668@mail.gmail.com>
References: <215036450609172228l21e8fb2drbdd880f7c1bfcc21@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
To: "Joe Jin" <lkmaillist@gmail.com>
In-Reply-To: <215036450609172228l21e8fb2drbdd880f7c1bfcc21@mail.gmail.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Only authors of proprietary modules you loaded can debug this.
Please, redirect this and all futher oopses to them.

On 9/18/06, Joe Jin <lkmaillist@gmail.com> wrote:
> while I try to transmit a 8k data by send() on my laptap T60,  kernel
> panic occured:

> Modules linked in: rds cisco_ipsec parport_pc lp parport autofs4
> pcmcia opw3945 ieee80211 ie80211_crypt ipt_REJECT xt_tcpudp x_tables
> vfat fat dm_mirror dm_mod ibm-acpi button battery ac yenta_socket
> rsrc_nonstatic pcmcia_core uhci_hcd ehci_hcd i2c_i801 i2c_core e1000
> ext3 jbd ahci libata sd_mod scsi_mod
> CPU:    0
> EIP:    0060:[<f8e02261>]       Tainted:        PF      VLI

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
