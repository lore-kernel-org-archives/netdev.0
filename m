From: Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH net-next 0/2] Introduce generic
	6LoWPAN branch
Date: Fri, 11 Jul 2014 13:25:04 +0300
Message-ID: <1405074304.9749.64.camel@jrissane-mobl.ger.corp.intel.com>
References: <1405067059-18782-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1405067059-18782-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Alex,

On pe, 2014-07-11 at 10:24 +0200, Alexander Aring wrote:
> Hi,
> 
> this patch series add a new branch "net/6lowpan" for generic 6LoWPAN code.
> 
> Since commit 8df8c56a5abc70af5862aa7cac2875aeeb17a42b ("6lowpan: Moving
> generic compression code into 6lowpan_iphc.c") the IPHC compression is shared
> between bluetooth 6LoWPAN and IEEE 802.15.4 6LoWPAN. The new 6LoWPAN directory
> will contain generic code for 6LoWPAN and futhermore 6LoWPAN upper layer
> protocols.
> 
> The shared code between bluetooth and 802.15.4 should be review from both
> communities. The current behaviour is that get_maintainers.pl returns the
> IEEE 802.15.4 community only.
> 
> 
> I request a new mailinglist for the IEEE 802.15.4 subsystem at vger but I didn't
> get a response now so I add the current sourceforge IEEE 802.15.4 mailinglist to
> the MAINTAINERS file. I will update them soon.

This is great idea.

Acked-by: Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>



------------------------------------------------------------------------------
Open source business process management suite built on Java and Eclipse
Turn processes into business applications with Bonita BPM Community Edition
Quickly connect people, data, and systems into organized workflows
Winner of BOSSIE, CODIE, OW2 and Gartner awards
http://p.sf.net/sfu/Bonitasoft
