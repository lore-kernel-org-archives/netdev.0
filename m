From: Kever Yang <kever.yang@rock-chips.com>
Subject: Re: [PATCH 0/4] support GMAC driver for RK3288
Date: Wed, 26 Nov 2014 12:05:59 +0800
Message-ID: <547551A7.2090700@rock-chips.com>
References: <1416906460-26078-1-git-send-email-roger.chen@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	mark.yao@rock-chips.com, eddie.cai@rock-chips.com
To: Roger Chen <roger.chen@rock-chips.com>, heiko@sntech.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416906460-26078-1-git-send-email-roger.chen@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Roger,

     Please use the --in-reply-to option for patches other than 0/4
with the git send-email.

On 11/25/2014 05:07 PM, Roger Chen wrote:
> Roger Chen (4):
>    patch1: add driver for Rockchip RK3288 SoCs integrated GMAC
>    patch2: modify CRU config for Rockchip RK3288 SoCs integrated GMAC
>    patch3: dts: add gmac info for rk3288
>    patch4: dts: enable gmac on RK3288 evb board
>
> tested on rk3288 SDK board:
> busybox ifconfig eth0 up
> busybox ifconfig eth0 192.168.1.111
> ping 192.168.1.1
>
