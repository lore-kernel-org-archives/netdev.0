From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.25-rc9: Reported regressions from 2.6.24
Date: Tue, 15 Apr 2008 15:16:06 +0200
Message-ID: <4804AA96.3080609@trash.net>
References: <RR4Oy_oXY2J.A.b0H.A3lAIB@albercik> <480262E9.4030500@trash.net> <480267C0.6020402@trash.net> <48026AAE.8040500@trash.net> <20080414203111.GB26591@gospo.usersys.redhat.com> <20080415131413.GC26591@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764767AbYDONQX@vger.kernel.org>
In-Reply-To: <20080415131413.GC26591@gospo.usersys.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek wrote:
> On Mon, Apr 14, 2008 at 04:31:11PM -0400, Andy Gospodarek wrote:
>> On Sun, Apr 13, 2008 at 10:18:54PM +0200, Patrick McHardy wrote:
>>>
>>> For now I suggest this fix. Andy, could you please test whether it
>>> fixes the problem?
>>>
>>>
>> I'm guessing it will.  I've been testing my older kernels today and
>> somehow I'm unable to reproduce the original problem, so I need to
>> figure out what is different about my config now and before.
>>
>> I'll definitely post back when I test this, but I wanted to make sure
>> you guys knew I was at least trying it. :)
>>
> 
> I just got done testing 159d83363b629c91d020734207c1bc788b96af5a and I
> can confirm that is resolves my issue.


Thanks Andy.
