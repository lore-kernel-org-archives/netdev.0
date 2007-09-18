From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] Blackfin EMAC driver: add function to change the
 MAC	address
Date: Tue, 18 Sep 2007 18:07:38 -0400
Message-ID: <46F04C2A.20500@garzik.org>
References: <1189911423.9901.4.camel@roc-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org
To: bryan.wu@analog.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759267AbXIRWHz@vger.kernel.org>
In-Reply-To: <1189911423.9901.4.camel@roc-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bryan Wu wrote:
>>From 157dfddae50708a716c2a42a314eccb9621d8793 Mon Sep 17 00:00:00 2001
> From: Alex Landau <lirsb@yahoo.com>
> Date: Sun, 5 Aug 2007 15:58:03 +0800
> Subject: [PATCH] Blackfin Ethernet MAC driver: add function to change the MAC address
> 
> Alex Landau writes in the forums:
>   Previously, changing the MAC address (e.g. via ifconfig) resulted
>   in a generic function to be called that only changed a variable in
>   memory. This patch also updated the Blackfin MAC address registers
>   to filter the correct new MAC.
> 
> Signed-off-by: Alex Landau <lirsb@yahoo.com>
> Signed-off-by: Mike Frysinger <michael.frysinger@analog.com>
> Signed-off-by: Bryan Wu <bryan.wu@analog.com>

ACK patches 1-3... but can you regenerate them against 
netdev-2.6.git#upstream (or davem/net-2.6.24.git)?
