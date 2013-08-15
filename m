From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCHv2 net-next] 6lowpan: handle only
 real link-local addresses
Date: Thu, 15 Aug 2013 00:38:35 -0700 (PDT)
Message-ID: <20130815.003835.1360686587921091943.davem@davemloft.net>
References: <20130814211658.GA2075@x61s.8.8.8.8>
	<20130814.171825.944941726261089646.davem@davemloft.net>
	<20130815045701.GA3110@x61s.8.8.8.8>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20130815045701.GA3110-P4zwP3w+81Pu/k754drY8A@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 15 Aug 2013 06:57:21 +0200

> Hi David,
> 
> On Wed, Aug 14, 2013 at 05:18:25PM -0700, David Miller wrote:
>> From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Date: Wed, 14 Aug 2013 23:17:01 +0200
>> 
>> > Ok, please let me know what should I do to submit it properly.
>> 
>> What you don't understand is that just because patches aren't
>> related doesn't mean that their order of application doesn't
>> matter.
>> 
> Ok. I got the information on an other mailinglist that I should
> not mix "features" and "fixes" in a single series. Then I just
> try to seperate...

If it's a fix it's destined for the 'net' tree not 'net-next'.

And in that case you first submit only the bug fix, then you
politely ask me after it's been included to merge 'net' into
'net-next' so you can then rebase your net-next patches and
submit them seperately.

------------------------------------------------------------------------------
Get 100% visibility into Java/.NET code with AppDynamics Lite!
It's a free troubleshooting tool designed for production.
Get down to code-level detail for bottlenecks, with <2% overhead. 
Download for free and get started troubleshooting in minutes. 
http://pubads.g.doubleclick.net/gampad/clk?id=48897031&iu=/4140/ostg.clktrk
