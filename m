From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next 3/6] 6lowpan: move
	6lowpan.c to 6lowpan_rtnl.c
Date: Sat, 22 Feb 2014 15:25:31 +0100
Message-ID: <20140222142530.GA2430@omega>
References: <1392995711-19563-1-git-send-email-alex.aring@gmail.com>
	<1392995711-19563-4-git-send-email-alex.aring@gmail.com>
	<1393076452.15717.98.camel@deadeye.wl.decadent.org.uk>
	<20140222140344.GA1032@omega>
	<1393078035.15717.103.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1393078035.15717.103.camel-nDn/Rdv9kqW9Jme8/bJn5UCKIB8iOfG2tUK59QYPAWc@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 22, 2014 at 02:07:15PM +0000, Ben Hutchings wrote:
> On Sat, 2014-02-22 at 15:03 +0100, Alexander Aring wrote:
> > Hi Ben,
> > 
> > thanks for your reply.
> > 
> > On Sat, Feb 22, 2014 at 01:40:52PM +0000, Ben Hutchings wrote:
> > > On Fri, 2014-02-21 at 16:15 +0100, Alexander Aring wrote:
> > > > We have a 6lowpan.c file and 6lowpan.ko file. To avoid confusing we
> > > > should move 6lowpan.c to 6lowpan.ko. Then we can support multiple source
> > > 
> > > You put the wrong filename here ^
> > > 
> > mhh, I meant here:
> [...]
> 
> I know what you mean, but the second '6lowpan.ko' in the description
> should surely be '6lowpan_rtnl.c' like in the subject.
> 
oh yes. Thanks. :-)

- Alex

------------------------------------------------------------------------------
Managing the Performance of Cloud-Based Applications
Take advantage of what the Cloud has to offer - Avoid Common Pitfalls.
Read the Whitepaper.
http://pubads.g.doubleclick.net/gampad/clk?id=121054471&iu=/4140/ostg.clktrk
