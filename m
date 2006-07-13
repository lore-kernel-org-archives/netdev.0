From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e1000 fails to load sometimes: The EEPROM Checksum Is Not Valid
Date: Thu, 13 Jul 2006 14:24:38 -0700
Message-ID: <44B6BA16.5040902@intel.com>
References: <44B69545.8000507@intel.com> <44B6B14A.3020001@goop.org> <44B6B43B.6000005@intel.com> <44B6B5FB.6070400@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	profilek@users.sourceforge.net, squat@users.sourceforge.net,
	NetDev <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:1285 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1030350AbWGMVZN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 17:25:13 -0400
To: Jeremy Fitzhardinge <jeremy@goop.org>
In-Reply-To: <44B6B5FB.6070400@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeremy Fitzhardinge wrote:
> Auke Kok wrote:
>> See:
>>
>> http://www-307.ibm.com/pc/support/site.wss/document.do?lndocid=MIGR-63027
>>
>> links to the latest .iso image.
>>
>> Note: I haven't tried the 1.07 update myself. I had to *downgrade* our 
>> test system to actually expose the bug. 
> This appears to be a link to the T60 1.06 update.  Do you know if 
> they're planning an X60 update too?

x60 bios upgrade 1.06 is here: (found by typing "x60 bios" in the search bar 
on the same website)

http://www-307.ibm.com/pc/support/site.wss/license.do?filename=mobiles/7buj04uc.iso

unfortunately the changelog for this BIOS upgrade doesn't tell us much if the 
DSPD feature was affected or not. I also have not tried this one either.

Cheers,

Auke
