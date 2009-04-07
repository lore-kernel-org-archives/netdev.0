From: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Subject: Re: No local loopback for mac80211_hwsim test setup
Date: Tue, 07 Apr 2009 21:07:03 +0200
Message-ID: <49DBA457.7060307@monom.org>
References: <20090403123822.GA26100@toronto053.server4you.de>	 (sfid-20090403_150647_912363_CB6A5CE6) <1238787032.11352.1.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1238787032.11352.1.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Fri, 2009-04-03 at 14:38 +0200, Daniel Wagner wrote:
> 
>> So my question is this possible what I'd like to do? If so, what's the
>> trick to get it working?
> 
> It's not possible locally, unfortunately, afaik.

Ok, I found workaround for my problem. I'm using a VM with a small
linux distro inside. The networking interface is bridge to the wlan
interface. With this setup I can have some services running and have
real traffic over the 'link'. Not really lightweight, but well, I
guess hardware vendors like this approach.

thanks,
daniel
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
