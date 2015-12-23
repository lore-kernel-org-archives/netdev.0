From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH V1 00/16] add Intel(R) X722 iWARP driver
Date: Wed, 23 Dec 2015 18:39:32 +0200
Message-ID: <567ACE44.20608@mellanox.com>
References: <1450739596-23276-1-git-send-email-faisal.latif@intel.com>
 <567AC754.5020508@redhat.com> <20151223163549.GA22244@flatif-MOBL1>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <e1000-rdma-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20151223163549.GA22244@flatif-MOBL1>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/23/2015 6:35 PM, Faisal Latif wrote:
> I will provide new patch series for latest k.o. Also will make sure of shallow threading for the series.

Please make sure that the cover letter will include the full output of 
the git generated cover-letter so we can see the location of changes you 
did to the IB core and the overall LOC volume of the driver.

Did you run the driver through 0-day testing to avoid zillion small 
follow up patches in a later point when this isin?

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
