From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH bluetooth-next] ieee802154: cc2520: Replace shift operations by BIT macro
Date: Sun, 1 Feb 2015 21:10:39 -0800
Message-ID: <9000AC78-D8DB-4FE3-86A1-666DE5A1295E@holtmann.org>
References: <1422021509-18877-1-git-send-email-md.jamalmohiuddin@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: varkabhadram@gmail.com, alex.aring@gmail.com,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mohammad Jamal <md.jamalmohiuddin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422021509-18877-1-git-send-email-md.jamalmohiuddin@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Mohammad,

> This patch replaces the shifting operations by BIT macro
> 
> Signed-off-by: Mohammad Jamal <md.jamalmohiuddin@gmail.com>
> ---
> drivers/net/ieee802154/cc2520.c |    6 +++---
> 1 file changed, 3 insertions(+), 3 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
