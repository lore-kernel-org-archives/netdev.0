From: Craig <craig@haquarter.de>
Subject: Re: [Bugme-new] [Bug 16383] New: Regression with e1000e from 2.6.34.1
 to 2.6.35-rc5
Date: Mon, 02 Aug 2010 23:23:36 +0200
Message-ID: <4C573758.5040104@haquarter.de>
References: <bug-16383-10286@https.bugzilla.kernel.org/> <20100721134843.f8b5b217.akpm@linux-foundation.org> <EA929A9653AAE14F841771FB1DE5A1365FFE8449AA@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:48614 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835Ab0HBVXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 17:23:38 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FFE8449AA@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> https://bugzilla.kernel.org/show_bug.cgi?id=16383

>>>
>>>            Summary: Regression with e1000e from 2.6.34.1 to 2.6.35-rc5
>>>            Product: Drivers
>>>            Version: 2.5
>>>     Kernel Version: 2.6.35
>>>           Platform: All
>>>         OS/Version: Linux
>>>               Tree: Mainline
>>>             Status: NEW
>>>           Severity: high
>>>           Priority: P1
>>>          Component: Network
>>>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>>>         ReportedBy: craig@haquarter.de
>>>         Regression: Yes
>>>
>>>
>>> Networking stops working with 2.6.35 (tested rc-3 and rc5).
>>
>> This is a post-2.6.34 regression, guys.  There's some more info in
>> bugzilla.

The e1000e works like a charm with 2.6.35, thanks everyone.

Best regards,

Craig
