From: ByeoungWook Kim <quddnr145@gmail.com>
Subject: Re: [PATCH v3] rtlwifi: Fix improve function 'rtl_addr_delay()' in core.c
Date: Wed, 3 Feb 2016 18:18:08 +0900
Message-ID: <CAOxTRzos-iFb5DCKzyz0y_XZgtsLi4uxhxH_3m_vaKrtLBZzjw@mail.gmail.com>
References: <20160203052146.GA15711@gmail.com>
	<20160203085603.GA9640@sudip-pc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Kalle Valo <kvalo@codeaurora.org>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	kbuild test robot <lkp@intel.com>,
	Julian Calaby <julian.calaby@gmail.com>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160203085603.GA9640@sudip-pc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sudip,

This patch is exsisted depencency like next.
http://marc.info/?l=linux-wireless&m=145447963305712&w=2

I wrote review and the followup patch.
but i seem to that don't write a Cc document.

Sorry for your confused.

Regards,
Byeoungwook.

2016-02-03 17:56 GMT+09:00 Sudip Mukherjee <sudipm.mukherjee@gmail.com>:
> On Wed, Feb 03, 2016 at 02:21:46PM +0900, Byeoungwook Kim wrote:
>> Conditional codes in rtl_addr_delay() were improved in readability and
>> performance by using switch codes.
>>
>> Reviewed-by: Julian Calaby <julian.calaby@gmail.com>
>> Signed-off-by: Byeoungwook Kim <quddnr145@gmail.com>
>> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
>
> How you are using Signed-off-by: of Fengguang Wu?
>
> did i missed seeing any mail from Fengguang in your previous versions?
>
> regards
> sudip
