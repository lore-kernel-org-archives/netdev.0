From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] iwlwifi: remove obsoleted module alias and parameters
Date: Wed, 06 Apr 2011 18:42:48 +0800
Message-ID: <4D9C43A8.5060500@redhat.com>
References: <1302083382-6715-1-git-send-email-amwang@redhat.com> <1302084582.3811.9.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Meenakshi Venkataraman <meenakshi.venkataraman@intel.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:26043 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750807Ab1DFKns (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2011 06:43:48 -0400
In-Reply-To: <1302084582.3811.9.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2011=E5=B9=B404=E6=9C=8806=E6=97=A5 18:09, Johannes Berg =E5=86=
=99=E9=81=93:
> On Wed, 2011-04-06 at 17:49 +0800, Amerigo Wang wrote:
>> As scheduled in Documentation/feature-removal-schedule.txt,
>> remove "*50", "disable_hw_scan" module parameters and MODULE_ALIAS("=
iwl4965").
>
> Mostly fine, but for iwlegacy Stanislaw we want to keep hw scan (and =
it
> was actually made default now)
>

Ok, I will wait for Stanislaw's response and then send an updated patch=
=2E

Thanks.
