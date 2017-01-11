From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Wed, 11 Jan 2017 01:05:39 -0800
Message-ID: <20170111090539.GA78804@knc-06.sc.intel.com>
References: <1481788782-89964-1-git-send-email-niranjana.vishwanathapura@intel.com>
 <20161215091226.GC811@mtr-leonro.local>
 <20161215145212.GA29116@phlsvsds.ph.intel.com>
 <380b05bf-a18e-1f20-7e8e-10b61f77dec7@redhat.com>
 <20170109075104.GV15685@mtr-leonro.local>
 <20170110033954.GA53664@knc-06.sc.intel.com>
 <20170110081402.GH7218@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "ira.weiny" <ira.weiny-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170110081402.GH7218-U/DQcQFIOTAAJjI8aNfphQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 10, 2017 at 10:14:02AM +0200, Leon Romanovsky wrote:
>On Mon, Jan 09, 2017 at 07:39:54PM -0800, Vishwanathapura, Niranjana wrote:
>> We are also looking into Jason’s suggestion to make hfi_vnic interface to
>> the bottom driver a generic interface. This will include moving some of the
>> netstack interfacing to the bottom hfi1 driver.
>
>Great, do you have rough estimation when will it be posted on the ML?
>
>Thanks
>

Hi Leon,

I am currently doing some prototype on this. I will respond with the interface 
definition first once I have it solidified. RFC v3 with implemetion will be 
later.

Niranjana


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
