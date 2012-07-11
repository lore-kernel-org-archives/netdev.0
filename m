From: Joe Jin <joe.jin@oracle.com>
Subject: Re: 82571EB: Detected Hardware Unit Hang
Date: Wed, 11 Jul 2012 13:03:04 +0800
Message-ID: <4FFD0908.6080506@oracle.com>
References: <4FFA9B96.6040901@oracle.com> <4FFBDC50.5090800@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA891274EE41F@ORSMSX102.amr.corp.intel.com> <4FFCCA22.8060006@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA891274EEC8B@ORSMSX102.amr.corp.intel.com> <4FFCDA6C.8020708@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA891274EED74@ORSMSX102.amr.corp.intel.com> <4FFCF314.6020400@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA891274EEDD7@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Dave, Tushar N" <tushar.n.dave@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA891274EEDD7@ORSMSX102.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/11/12 12:05, Dave, Tushar N wrote:
> When you said you had this issue with RHEL5 and RHEL6 drivers, have you install RHEl5/6 kernel and reproduced it? If so I think I should install RHEL6 and try reproduce it locally!
> 
Yes I reproduced this on both RHEL5 and RHEL6.

So far I tried to scp big file (~1GB) will hit it at once.

Thanks,
Joe
