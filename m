From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Any plan for inclusion of linux-wlan-ng ?
Date: Sun, 11 Apr 2004 17:05:23 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <4079B313.7010907@pobox.com>
References: <plopm3lll26bsg.fsf@drizzt.kilobug.org> <20040411164011.GA21257@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ga?l Le Mignot <kilobug@freesurf.fr>, linux-kernel@vger.kernel.org,
	Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Greg KH <greg@kroah.com>
In-Reply-To: <20040411164011.GA21257@kroah.com>
List-Id: netdev.vger.kernel.org

Greg KH wrote:
> On Sun, Apr 11, 2004 at 12:37:03PM +0200, Ga?l Le Mignot wrote:
> 
>>Hello,
>>
>>I was just  wondering is there is any  plan of including linux-wlan-ng
>>into  the 2.6  kernel. Does  someone know  about that  ? If  not, does
>>someone know why ?
> 
> 
> The authors have never submitted it?  Or wanted to?

Never submitted AFAIK, but regardless...

There is a central problem of multiple 802.11 stacks that I very much 
want to avoid.  linux-wlan-ng, HostAP, madwifi, and one or two others.

I had hoped that HostAP would be submitted, and that could form the 
basis of a common 802.11 stack, but I haven't heard anything about that 
in many weeks.

	Jeff
