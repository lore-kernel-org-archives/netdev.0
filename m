From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] iwlwifi: remove obsoleted module alias and parameters
Date: Wed, 13 Apr 2011 19:53:47 +0800
Message-ID: <4DA58ECB.9060602@redhat.com>
References: <1302083382-6715-1-git-send-email-amwang@redhat.com> <1302084582.3811.9.camel@jlt3.sipsolutions.net> <4D9C43A8.5060500@redhat.com> <20110406125728.GA2197@redhat.com> <20110412204941.GD24309@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Intel Linux Wireless <ilw@linux.intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Meenakshi Venkataraman <meenakshi.venkataraman@intel.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29804 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750851Ab1DMLyP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 07:54:15 -0400
In-Reply-To: <20110412204941.GD24309@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2011=E5=B9=B404=E6=9C=8813=E6=97=A5 04:49, John W. Linville =E5=
=86=99=E9=81=93:
> On Wed, Apr 06, 2011 at 02:57:29PM +0200, Stanislaw Gruszka wrote:
>> On Wed, Apr 06, 2011 at 06:42:48PM +0800, Cong Wang wrote:
>>> =E4=BA=8E 2011=E5=B9=B404=E6=9C=8806=E6=97=A5 18:09, Johannes Berg =
=E5=86=99=E9=81=93:
>>>> On Wed, 2011-04-06 at 17:49 +0800, Amerigo Wang wrote:
>>>>> As scheduled in Documentation/feature-removal-schedule.txt,
>>>>> remove "*50", "disable_hw_scan" module parameters and MODULE_ALIA=
S("iwl4965").
>>>>
>>>> Mostly fine, but for iwlegacy Stanislaw we want to keep hw scan (a=
nd it
>>>> was actually made default now)
>>
>> Indeed, disable_hw_scan should be removed in iwlwifi but leaved in i=
wlegacy.
>>
>>> Ok, I will wait for Stanislaw's response and then send an updated p=
atch.
>>
>> Have it now :-)
>
> Ping?
>

Huh?

The same patch from Wey-yi was merged as commit#7eaa6a5e964f1ab02d849bd=
a36950c0d30be8ce2,
no?
