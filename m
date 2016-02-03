From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH] rtlwifi: Fix reusable codes in core.c
Date: Wed, 3 Feb 2016 11:54:38 +1100
Message-ID: <CAGRGNgXuCfpRVuM7Dxt9QT9TGW1zt9Qh+pqSPJ_X5zHq3A4v4w@mail.gmail.com>
References: <20160202154855.GA8990@gmail.com> <CAGRGNgVHEsA693tQxf0Mv_4wSu-4wG7sphhRRB0gbU6o9nzZ_Q@mail.gmail.com>
 <CAOxTRzoGkNUy2FRUQLg_01D5p6Bjxfs+w8iEJJrkM2pTdkdC5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kalle Valo <kvalo@codeaurora.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: ByeoungWook Kim <quddnr145@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOxTRzoGkNUy2FRUQLg_01D5p6Bjxfs+w8iEJJrkM2pTdkdC5Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi ByeoungWook,

On Wed, Feb 3, 2016 at 11:52 AM, ByeoungWook Kim <quddnr145@gmail.com> wrote:
> Hi Julian,
>
> 0xfe and 0xfb was not same codes.
> 0xfe is udelay(50). and 0xfb is mdelay(50).
> It same code like udelay((n) * 1000).

I'm clearly blind! Sorry about that!

> but i agree with your answers of some parts. I think that i should divide
> into separate patch.
> Thanks for your assists!

Not a problem!

Thanks,

-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
