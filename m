From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: [fw@deneb.enyo.de: Route cache performance under stress]
Date: Sun, 06 Apr 2003 18:42:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <87wui71st8.fsf@deneb.enyo.de>
References: <20030405165016.GA32361@outpost.ds9a.nl>
	<20030405134350.N68419@shell.cyberus.ca>
	<873ckwftal.fsf@deneb.enyo.de>
	<20030405180607.P68419@shell.cyberus.ca>
	<87n0j3ltf0.fsf@deneb.enyo.de>
	<20030406110728.G68419@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <20030406110728.G68419@shell.cyberus.ca> (jamal's message of
 "Sun, 6 Apr 2003 11:14:50 -0400 (EDT)")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal <hadi@cyberus.ca> writes:

> cat /proc/net/rt_cache_stat
> Should give us a lot more info.

I'll try to obtain the data points you requested.

>> > Our data was collected on a real ISP which hosts a lot of web
>> > servers and was being constantly DOSed. I dont think you can get
>> > more real world than that.
>>
>> Did you look at a router, or at a host?
>
> As a router, but the hash compute shouldnt matter.

Slow path ist faster on hosts than on routers which substantial
routing tables, isn't it?
