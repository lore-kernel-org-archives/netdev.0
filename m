From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1] linux-firmware: Add QLogic BR Series Adapter
 Firmware
Date: Tue, 17 Feb 2015 14:40:51 -0800
Message-ID: <1424212851.25416.6.camel@perches.com>
References: <1424209981-28373-1-git-send-email-rasesh.mody@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-firmware@kernel.org, NetDev <netdev@vger.kernel.org>,
	linux-scsi@vger.kernel.org
To: Rasesh Mody <rasesh.mody@qlogic.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1424209981-28373-1-git-send-email-rasesh.mody@qlogic.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-02-17 at 16:53 -0500, Rasesh Mody wrote:
> This patch rebrands the BFA/BNA inbox driver firmwares.
> This patch adds 3.2.5.1 firmware files for QLogic BR-series Adapters that will
> be used with the inbox drivers(BFA and BNA).
> 
> Signed-off-by: Rasesh Mody <rasesh.mody@qlogic.com>
> ---
>  WHENCE            |  13 +++++++++----
>  cbfw-3.2.5.1.bin  | Bin 0 -> 414480 bytes
>  ct2fw-3.2.5.1.bin | Bin 0 -> 584216 bytes
>  ctfw-3.2.5.1.bin  | Bin 0 -> 539144 bytes
>  4 files changed, 9 insertions(+), 4 deletions(-)
>  create mode 100755 cbfw-3.2.5.1.bin
>  create mode 100755 ct2fw-3.2.5.1.bin
>  create mode 100755 ctfw-3.2.5.1.bin

644 instead of 755 please.


