From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net-next v2] r8169:add support for RTL8168H and RTL8107E
Date: Mon, 08 Sep 2014 15:00:45 +0200
Message-ID: <540DA87D.9000302@redhat.com>
References: <1408470844-30038-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, linux-kernel@vger.kernel.org,
	romieu@fr.zoreil.com
To: Chun-Hao Lin <hau@realtek.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408470844-30038-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19.8.2014 19:54, Chun-Hao Lin wrote:
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 91652e7..c8375f6 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -52,6 +52,10 @@
>   #define FIRMWARE_8106E_2	"rtl_nic/rtl8106e-2.fw"
>   #define FIRMWARE_8168G_2	"rtl_nic/rtl8168g-2.fw"
>   #define FIRMWARE_8168G_3	"rtl_nic/rtl8168g-3.fw"
> +#define FIRMWARE_8168H_1	"rtl_nic/rtl8168h-1.fw"
> +#define FIRMWARE_8168H_2	"rtl_nic/rtl8168h-2.fw"
> +#define FIRMWARE_8107E_1	"rtl_nic/rtl8107e-1.fw"
> +#define FIRMWARE_8107E_2	"rtl_nic/rtl8107e-2.fw"

Where are these new firmware files ^^^^ located? They are missing at 
git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git

Ivan
