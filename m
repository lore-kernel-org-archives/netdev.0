From: "Luis R. Rodriguez" <lrodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 6/8] drivers/net/wireless/ath/ath9k: use ARRAY_SIZE
 macro in ani.c
Date: Wed, 8 Sep 2010 14:31:28 -0700
Message-ID: <20100908213128.GD1783@tux>
References: <1283979457-4649-1-git-send-email-nikitasangelinas@gmail.com>
 <1283981142-5062-1-git-send-email-nikitasangelinas@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Luis Rodriguez <Luis.Rodriguez-R2DSYHpuZhhBDgjK7y7TUQ@public.gmane.org>,
	Jouni Malinen <Jouni.Malinen-R2DSYHpuZhhBDgjK7y7TUQ@public.gmane.org>,
	Vasanth Thiagarajan <Vasanth.Thiagarajan-R2DSYHpuZhhBDgjK7y7TUQ@public.gmane.org>,
	Senthilkumar Balasubramanian
	<Senthilkumar.Balasubramanian-R2DSYHpuZhhBDgjK7y7TUQ@public.gmane.org>,
	"linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Sujith Manoharan <Sujith.Manoharan-R2DSYHpuZhhBDgjK7y7TUQ@public.gmane.org>,
	"nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org" <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org" <ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Nikitas Angelinas <nikitasangelinas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1283981142-5062-1-git-send-email-nikitasangelinas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 08, 2010 at 02:25:42PM -0700, Nikitas Angelinas wrote:
> Replace (sizeof(ofdm_level_table)/sizeof(ofdm_level_table[0]) with
> ARRAY_SIZE(ofdm_level_table), and (sizeof(cck_level_table)/
> sizeof(cck_level_table[0]) with ARRAY_SIZE(cck_level_table) in
> drivers/net/wireless/ath/ath9k/ani.c
> 
> Signed-off-by: Nikitas Angelinas <nikitasangelinas-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Sure.

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
