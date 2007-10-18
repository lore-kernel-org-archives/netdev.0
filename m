From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH][NET] gianfar: fix obviously wrong #ifdef CONFIG_GFAR_NAPI
 placement
Date: Wed, 17 Oct 2007 20:21:32 -0400
Message-ID: <4716A70C.6090307@garzik.org>
References: <20071017195746.GA15592@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, paulus@samba.org, galak@kernel.crashing.org,
	afleming@freescale.com, apw@shadowen.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760220AbXJRAWU@vger.kernel.org>
In-Reply-To: <20071017195746.GA15592@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anton Vorontsov wrote:
> Erroneous #ifdef introduced by 293c8513398657f6263fcdb03c87f2760cf61be4
> causing NAPI-less ethernet malfunctioning.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> Signed-off-by: Vitaly Bordug <vbordug@ru.mvista.com>

applied
