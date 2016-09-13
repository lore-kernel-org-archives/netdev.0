From: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Subject: Re: [RFC 00/11] QLogic RDMA Driver (qedr) RFC
Date: Tue, 13 Sep 2016 17:23:44 +0300
Message-ID: <317f85a5-8890-e02e-6093-876f61aed1b5@grimberg.me>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1473696465-27986-1-git-send-email-Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hey Ram and Co,

> This series introduces RoCE RDMA driver for the 579xx RDMA products by Qlogic.
> The RDMA support is added as an additional loadable module (qedr) over the Ethernet qede driver.
> The qedr module will support both RoCE and iWarp, although this series only adds RoCE support.
> The qed and qede drivers are enhanced with functionality required for RDMA support.
>
> Any review/comment is appreciated.

Was this driver tested with any of our kernel consumers (nfs/iser/nvmf)?

If so, are there known issues?

Thanks,
Sagi.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
