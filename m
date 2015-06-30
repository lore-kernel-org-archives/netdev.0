From: Joe Perches <joe@perches.com>
Subject: Re: [Intel-wired-lan] [PATCH 1/1] igb: Use ARRAY_SIZE instead fo
 sizeof(a)/sizeof(a[0])
Date: Tue, 30 Jun 2015 15:32:40 -0700
Message-ID: <1435703560.12101.51.camel@perches.com>
References: <1435640130-1466-1-git-send-email-maninder1.s@samsung.com>
	 <9B4A1B1917080E46B64F07F2989DADD653571921@ORSMSX114.amr.corp.intel.com>
	 <CAFLxGvxayeac0Hq8Gi5j_TJ4dnboYypz9gchW0VQ0Z9t-UFofA@mail.gmail.com>
	 <9B4A1B1917080E46B64F07F2989DADD653571BF0@ORSMSX114.amr.corp.intel.com>
	 <9B4A1B1917080E46B64F07F2989DADD653571DD7@ORSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Richard Weinberger <richard.weinberger@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Maninder Singh <maninder1.s@samsung.com>,
	"pankaj.m@samsung.com" <pankaj.m@samsung.com>
To: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0191.hostedemail.com ([216.40.44.191]:58286 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751042AbbF3Wco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 18:32:44 -0400
In-Reply-To: <9B4A1B1917080E46B64F07F2989DADD653571DD7@ORSMSX114.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-30 at 22:25 +0000, Fujinaka, Todd wrote:
> I've submitted a version to intel-wired-lan that addresses the original
> issue as well as Joe Perches's suggestion to just delete the define.

Please cc netdev next time too.
