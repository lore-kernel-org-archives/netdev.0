From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: e1000 fails to load sometimes: The EEPROM Checksum Is Not Valid
Date: Thu, 13 Jul 2006 13:59:39 -0700
Message-ID: <44B6B43B.6000005@intel.com>
References: <44B69545.8000507@intel.com> <44B6B14A.3020001@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: profilek@users.sourceforge.net, squat@users.sourceforge.net,
	NetDev <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:36156 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1030388AbWGMVAf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 17:00:35 -0400
To: Jeremy Fitzhardinge <jeremy@goop.org>
In-Reply-To: <44B6B14A.3020001@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeremy Fitzhardinge wrote:
> Auke Kok wrote:
>> Sorry for the long wait, there's some new information on this that 
>> just this morning arrived.
> Thanks for the update.
> 
>> The latest EEPROM's from Lenovo (obtainable from their websites as 
>> .iso) seem to have this feature turned off, which resolves the issue.
> 
> Do you have a specific link to this update?  I can't see anything 
> obvious on their site relating to this.

See:

http://www-307.ibm.com/pc/support/site.wss/document.do?lndocid=MIGR-63027

links to the latest .iso image.

Note: I haven't tried the 1.07 update myself. I had to *downgrade* our test 
system to actually expose the bug.

Cheers,

Auke
