From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH 0/2] net: thunderx: Miscellaneous cleanups
Date: Mon,  7 Dec 2015 10:30:31 +0530
Message-ID: <1449464433-43343-1-git-send-email-sunil.kovvuri@gmail.com>
References: <y>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	p.fedin@samsung.com, Sunil.Goutham@caviumnetworks.com,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <y>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch series contains contains couple of cleanup patches.

Sunil Goutham (1):
  net, thunderx: Remove unnecessary rcv buffer start address management

Yury Norov (1):
  net: thunderx: nicvf_queues: nivc_*_intr: remove duplication

 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |  189 +++++---------------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |   10 +-
 2 files changed, 51 insertions(+), 148 deletions(-)
