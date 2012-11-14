From: Joe Jin <joe.jin@oracle.com>
Subject: Re: 82571EB: Detected Hardware Unit Hang
Date: Wed, 14 Nov 2012 10:47:50 +0800
Message-ID: <50A30656.6090508@oracle.com>
References: <509B5038.8090304@oracle.com> <061C8A8601E8EE4CA8D8FD6990CEA89133487884@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Mary Mcgrath <mary.mcgrath@oracle.com>
To: "Dave, Tushar N" <tushar.n.dave@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA89133487884@ORSMSX102.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/09/12 04:35, Dave, Tushar N wrote:
> All devices in path from root complex to 82571, should have *same* max payload size otherwise it can cause hang. 
> Can you double check this?

Hi Tushar,

Checked with hardware vendor and they said no way to modify the max payload size 
from BIOS, can I modify it from driver side?

Thanks,
Joe
