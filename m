From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 0/1] af_iucv: don't use paged skbs for TX on HiperSockets
Date: Tue, 10 Jan 2017 17:10:33 +0100
Message-ID: <20170110161034.82445-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        stable@vger.kernel.org, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

here is an af_iucv patch built for the net-tree.

Thanks, Ursula

Julian Wiedmann (1):
  net/af_iucv: don't use paged skbs for TX on HiperSockets

 net/iucv/af_iucv.c | 25 ++++++++++++++-----------
 1 file changed, 14 insertions(+), 11 deletions(-)

-- 
2.8.4
