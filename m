From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: 82571EB: Detected Hardware Unit Hang
Date: Wed, 14 Nov 2012 03:45:30 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA8913348B105@ORSMSX102.amr.corp.intel.com>
References: <509B5038.8090304@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA89133487884@ORSMSX102.amr.corp.intel.com>
 <50A30656.6090508@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Mary Mcgrath <mary.mcgrath@oracle.com>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50A30656.6090508@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Joe Jin [mailto:joe.jin@oracle.com]
>Sent: Tuesday, November 13, 2012 6:48 PM
>To: Dave, Tushar N
>Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>kernel@vger.kernel.org; Mary Mcgrath
>Subject: Re: 82571EB: Detected Hardware Unit Hang
>
>On 11/09/12 04:35, Dave, Tushar N wrote:
>> All devices in path from root complex to 82571, should have *same* max
>payload size otherwise it can cause hang.
>> Can you double check this?
>
>Hi Tushar,
>
>Checked with hardware vendor and they said no way to modify the max
>payload size from BIOS, can I modify it from driver side?

If you want to change value for 82571 device you can do it from eeprom but for other upstream devices I am not sure. I will check with my team.

-Tushar
