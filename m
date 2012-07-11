From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: 82571EB: Detected Hardware Unit Hang
Date: Wed, 11 Jul 2012 07:11:43 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA891274EEF38@ORSMSX102.amr.corp.intel.com>
References: <4FFA9B96.6040901@oracle.com> <4FFBDC50.5090800@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274EE41F@ORSMSX102.amr.corp.intel.com>
 <4FFCCA22.8060006@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274EEC8B@ORSMSX102.amr.corp.intel.com>
 <4FFCDA6C.8020708@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274EED74@ORSMSX102.amr.corp.intel.com>
 <4FFCF314.6020400@oracle.com>
 <061C8A8601E8EE4CA8D8FD6990CEA891274EEDD7@ORSMSX102.amr.corp.intel.com>
 <4FFD0908.6080506@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Dave, Tushar N" <tushar.n.dave@intel.com>
To: Joe Jin <joe.jin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FFD0908.6080506@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>-----Original Message-----
>From: Joe Jin [mailto:joe.jin@oracle.com]
>Sent: Tuesday, July 10, 2012 10:03 PM
>To: Dave, Tushar N
>Cc: e1000-devel@lists.sf.net; netdev@vger.kernel.org; linux-
>kernel@vger.kernel.org
>Subject: Re: 82571EB: Detected Hardware Unit Hang
>
>On 07/11/12 12:05, Dave, Tushar N wrote:
>> When you said you had this issue with RHEL5 and RHEL6 drivers, have you
>install RHEl5/6 kernel and reproduced it? If so I think I should install
>RHEL6 and try reproduce it locally!
>>
>Yes I reproduced this on both RHEL5 and RHEL6.
>
>So far I tried to scp big file (~1GB) will hit it at once.
>
>Thanks,
>Joe

Joe,
Can you please send lspci -vvv output for failing port before issue occurs.
Thanks.

-Tushar
