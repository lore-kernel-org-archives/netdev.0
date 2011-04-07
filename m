From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] iwlwifi: remove obsoleted module alias and parameters
Date: Thu, 07 Apr 2011 15:17:53 +0800
Message-ID: <4D9D6521.5070607@redhat.com>
References: <1302083382-6715-1-git-send-email-amwang@redhat.com> <1302098755.14995.112.camel@wwguy-huron>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	"Venkataraman, Meenakshi" <meenakshi.venkataraman@intel.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: "Guy, Wey-Yi" <wey-yi.w.guy@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52288 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751674Ab1DGHSP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 03:18:15 -0400
In-Reply-To: <1302098755.14995.112.camel@wwguy-huron>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2011=E5=B9=B404=E6=9C=8806=E6=97=A5 22:05, Guy, Wey-Yi =E5=86=
=99=E9=81=93:
> On Wed, 2011-04-06 at 02:49 -0700, Amerigo Wang wrote:
>> As scheduled in Documentation/feature-removal-schedule.txt,
>> remove "*50", "disable_hw_scan" module parameters and MODULE_ALIAS("=
iwl4965").
>>
>> Cc: Intel Linux Wireless<ilw@linux.intel.com>
>> Cc: Johannes Berg<johannes.berg@intel.com>
>> Cc: "John W. Linville"<linville@tuxdriver.com>
>> Cc: Wey-Yi Guy<wey-yi.w.guy@intel.com>
>> Cc: Stanislaw Gruszka<sgruszka@redhat.com>
>> Cc: Meenakshi Venkataraman<meenakshi.venkataraman@intel.com>
>> Cc: Larry Finger<Larry.Finger@lwfinger.net>
>> Signed-off-by: WANG Cong<amwang@redhat.com>
>>
>> ---
> what tree you are base on?
> please check commit#7eaa6a5e964f1ab02d849bda36950c0d30be8ce2 in
> wireless-next-2.6

The latest Linus tree, sorry that I didn't know wireless has its own tr=
ee,
I just checked wireless-next-2.6 but don't find any commit matched
that commit ID, but I assume you meant you already sent a same patch?
If yes, feel free to discard mine.

Thanks.
