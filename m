From: Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Thu, 24 Nov 2016 17:31:23 +0200
Message-ID: <56cc60dc-f0f2-a9d4-75d1-da8f2f60531e@gmail.com>
References: <201611111820.52072@pali> <201611221805.13606@pali>
 <20161123222335.GA4788@amd> <201611232339.59411@pali>
 <20161124075104.GA26721@amd> <20161124083329.GB13735@pali>
 <20161124151317.34yoza3dzuh46oa4@earth> <20161124152045.GK13735@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: =?UTF-8?Q?Pali_Roh=c3=a1r?= <pali.rohar@gmail.com>,
        Sebastian Reichel <sre@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161124152045.GK13735@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 24.11.2016 17:20, Pali Rohár wrote:
>
> In case when wl1251 is statically linked into kernel image, it is loaded
> and initialized before even userspace applications starts.
>

Which leaves no option, but integrating libcal into kernel :).

Ivo
