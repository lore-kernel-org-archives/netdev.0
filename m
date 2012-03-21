From: Knut Petersen <Knut_Petersen@t-online.de>
Subject: Re: [PATCH] sky2: override for PCI legacy power management
Date: Wed, 21 Mar 2012 16:56:58 +0100
Message-ID: <4F69FA4A.3010909@t-online.de>
References: <4F69BE2E.7070903@t-online.de> <20120321083205.360a7a3b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>, arekm@maven.pl,
	Jared <nitro@legroom.net>, dilieto@lineone.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120321083205.360a7a3b@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks a lot!

> Some BIOS's don't setup power management correctly (what else is
> new) and don't allow use of PCI Express power control. Add a special
> exception module parameter to allow working around this issue.
> Based on slightly different patch by Knut Petersen.
>
> Reported-by: Arkadiusz Miskiewicz<arekm@maven.pl>
> Signed-off-by: Stephen Hemminger<shemminger@vyatta.com>
>
