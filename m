From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 01/14] Bluetooth: use list_for_each_entry*
Date: Sun, 20 Dec 2015 08:13:11 +0100
Message-ID: <9F80B03D-AE19-446F-87EC-244BEBABBBFD@holtmann.org>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geliang Tang <geliangtang@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Geliang,

> Use list_for_each_entry*() instead of list_for_each*() to simplify
> the code.
> 
> Signed-off-by: Geliang Tang <geliangtang@163.com>
> ---
> net/bluetooth/af_bluetooth.c | 12 ++++++------
> net/bluetooth/cmtp/capi.c    |  8 ++------
> net/bluetooth/hci_core.c     |  8 +++-----
> net/bluetooth/rfcomm/core.c  | 46 ++++++++++++++------------------------------
> 4 files changed, 25 insertions(+), 49 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
