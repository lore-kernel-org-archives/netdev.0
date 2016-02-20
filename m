From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] Bluetooth: hci_core: cancel power off delayed work properly
Date: Sat, 20 Feb 2016 00:12:23 -0800
Message-ID: <B2631016-F0BA-4938-BAA3-66456FA99EDD@holtmann.org>
References: <1455527391-13622-1-git-send-email-wnhuang@google.com>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Bluetooth <linux-bluetooth@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Johan Hedberg <johan.hedberg@intel.com>, snanda@chromium.org,
	djkurtz@chromium.org, "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Wei-Ning Huang <wnhuang@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455527391-13622-1-git-send-email-wnhuang@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Wei-Ning,

> When the HCI_AUTO_OFF flag is cleared, the power_off delayed work need
> to be cancel or HCI will be powered off even if it's managed.
> 
> Signed-off-by: Wei-Ning Huang <wnhuang@chromium.org>
> ---
> net/bluetooth/hci_core.c | 1 +
> 1 file changed, 1 insertion(+)

patch has been applied to bluetooth-next tree.

Regards

Marcel
