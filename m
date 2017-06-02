From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [for-next 4/6] net/mlx5: FPGA, Add basic support for Innova
Date: Fri, 02 Jun 2017 16:33:39 -0400
Message-ID: <1496435619.7171.107.camel@redhat.com>
References: <20170523114404.20387-1-saeedm@mellanox.com>
         <20170523114404.20387-5-saeedm@mellanox.com>
         <20170524165059.42lmrwzzcxvi2sf7@ast-mbp>
         <AM4PR0501MB1940885C2F1CEF4DDE4EA8D1DBFF0@AM4PR0501MB1940.eurprd05.prod.outlook.com>
         <CALzJLG-B_tAmASn_SMmPNiucq-tTpywHniRTkb4N32oGF6Y3Ng@mail.gmail.com>
         <00716e5a-8b51-0b3f-a1b8-1bb7b346a66a@fb.com>
         <CALzJLG9YNpagdJAcrh6O0jJhZWtsck6KigRtVxyjkArTm=82ew@mail.gmail.com>
         <f47d7519-4f58-bc94-2387-20342afd91b8@fb.com>
         <AM4PR0501MB19406FF2555888457C00E217DBF20@AM4PR0501MB1940.eurprd05.prod.outlook.com>
         <4c164e09-0103-7daf-e9f8-9260223ada08@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Kernel Team <kernel-team-b10kYP2dOMg@public.gmane.org>
To: Jes Sorensen <jsorensen-b10kYP2dOMg@public.gmane.org>, Ilan Tayari <ilant-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4c164e09-0103-7daf-e9f8-9260223ada08-b10kYP2dOMg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-06-02 at 16:31 -0400, Jes Sorensen wrote:
> 
> > It is already modular like that. See CONFIG_MLX5_FPGA.
> 
> [jes@xpeas netdev.git]$ grep CONFIG_MLX5_FPGA 
> drivers/net/ethernet/mellanox/mlx5/core/*
> [jes@xpeas netdev.git]$
> 
> Which git tree am I supposed to look at?

net-next

-- 
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG KeyID: B826A3330E572FDD
   
Key fingerprint = AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FDD

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
