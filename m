From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 1/1 net-next] Bluetooth: hidp: replace kzalloc/copy_from_user by memdup_user
Date: Sat, 15 Nov 2014 09:31:51 +0900
Message-ID: <7620CAF7-8060-4C5A-8055-53595B7B78F0@holtmann.org>
References: <1415990105-28609-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0 (Mac OS X Mail 8.0 \(1990.1\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415990105-28609-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Fabian,

> use memdup_user for rd_data import.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
> net/bluetooth/hidp/core.c | 10 +++-------
> 1 file changed, 3 insertions(+), 7 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
