From: jamal <hadi@cyberus.ca>
Subject: Re: cls_u32 compile failure in current 2.6.12-rc1+BK tree
Date: 28 Mar 2005 14:28:49 -0500
Message-ID: <1112038128.1119.5.camel@jzny.localdomain>
References: <Pine.SOC.4.61.0503272249040.5086@math.ut.ee>
	 <1111972035.1091.946.camel@jzny.localdomain>
	 <Pine.SOC.4.61.0503281017060.21333@math.ut.ee>
	 <1112012657.1089.1013.camel@jzny.localdomain>
	 <20050328123801.GY3086@postel.suug.ch>
	 <1112014261.1089.1018.camel@jzny.localdomain>
	 <20050328125802.GZ3086@postel.suug.ch>
	 <1112015725.1089.1045.camel@jzny.localdomain>
	 <20050328155523.GD3086@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Meelis Roos <mroos@linux.ee>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050328155523.GD3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-03-28 at 10:55, Thomas Graf wrote:
> * jamal <1112015725.1089.1045.camel@jzny.localdomain> 2005-03-28 08:15
> > On Mon, 2005-03-28 at 07:58, Thomas Graf wrote:

> > But you cant completely do this for u32 tcf_exts_dump_stats.
> > in the case of ACTION compiled in but someone using old API.
> > The code that Meelis just mention that compiler complained about. 
> > There was no problem with u32 and tcf_exts_dump - with that you can hide
> > all #ifedfs. 
> 
> I think we can avoid your fixes. 

You are still missing the question;->

You can do this for every classifier but u32. Or is it me who is missing
something?

cheers,
jamal
