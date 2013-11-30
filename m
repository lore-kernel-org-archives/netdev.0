From: Christian Kujau <lists@nerdbynature.de>
Subject: Re: 3.13-rc1: eth0 hw csum failure on powerpc
Date: Sat, 30 Nov 2013 13:16:34 -0800 (PST)
Message-ID: <alpine.DEB.2.11.1311301314220.31521@trent.utfs.org>
References: <alpine.DEB.2.11.1311300156380.31521@trent.utfs.org>
 <alpine.DEB.2.11.1311300210360.31521@trent.utfs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 Alexander Graf <agraf@suse.de>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <alpine.DEB.2.11.1311300210360.31521@trent.utfs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

On Sat, 30 Nov 2013 at 02:11, Christian Kujau wrote:
> On Sat, 30 Nov 2013 at 02:07, Christian Kujau wrote:
> > while trying to upgrade from 3.12.0 to 3.13-rc1 or -rc2, the following 
> > happens early during bootup:
> > 
> > [...]
> >  Freeing unused kernel memory: 204K (c06ea000 - c071d000)
> >  eth0: hw csum failure
> >  CPU: 0 PID: 0 Comm: swapper Not tainted 3.13.0-rc2 #1
> >  Call Trace:
> 
> Btw, full dmesg & .config:  http://nerdbynature.de/bits/3.13-rc1/

Oh, this has already been reported earlier this week:

https://lists.ozlabs.org/pipermail/linuxppc-dev/2013-November/113584.html

Christian.
-- 
BOFH excuse #53:

Little hamster in running wheel had coronary; waiting for replacement to be Fedexed from Wyoming
