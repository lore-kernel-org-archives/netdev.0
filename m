From: Jon Oberheide <jon@focalhost.com>
Subject: ARC4 crypto module
Date: Thu, 04 Mar 2004 11:07:39 -0500
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Message-ID: <1078416459.15115.65.camel@latitude>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hostap@shmoo.com
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: orinoco-devel@lists.sourceforge.net
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://sisyphus.iocaine.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

*** This message has been cross-posted to hostap@shmoo.com and
netdev@oss.sgi.com ***

Developers,

The ARC4 module I wrote for the crypto API has recently been included in
the 2.4 and 2.6 kernel.  Host-based WEP can now be implemented
relatively easily in wireless drivers.  I know HostAP has its own crypto
system but using the kernel crypto API for WEP is one step closer to
getting HostAP into the kernel.  The module should be in the next bk
snapshot for those interested.


Regards,
Jon Oberheide


On Thu, 2004-03-04 at 03:12, David S. Miller wrote:
> Applied to 2.6.x, thanks.
> 
> James, please cook up a 2.4.x variant as well.
