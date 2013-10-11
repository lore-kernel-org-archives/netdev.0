From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH] usbnet: smsc95xx: Add device tree input for MAC address
Date: Fri, 11 Oct 2013 09:51:38 +0800
Message-ID: <CACVXFVM2V6k6r4D5BPj7FyrBcGzopT5QVfww5fEUz6CfHMQTBQ@mail.gmail.com>
References: <1380911156-14112-1-git-send-email-dmurphy@ti.com>
	<CACVXFVOVMvP=3y9h2Jrqn2sBQdKOZtrhQDAFYkdHKXFgQj=d0Q@mail.gmail.com>
	<52519E7A.40804@ti.com>
	<CACVXFVNAB3VnmdoP_LGJsBjQ17j1aoqKMsBE7LRt65OqROeRUQ@mail.gmail.com>
	<525698CC.3060406@ti.com>
	<CACVXFVP-KgqcNTnk+JZsLc188pYk6iUXvW6=kPXNaurSuevGeA@mail.gmail.com>
	<5256A1DE.8010709@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>, mugunthanvnm@ti.com
To: Dan Murphy <dmurphy@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5256A1DE.8010709@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 10, 2013 at 8:47 PM, Dan Murphy <dmurphy@ti.com> wrote:
>
> Is there a board that has 2 built in smsc devices?

I don't know, maybe there isn't, but driver should be generic enough, and
as I said it is a generic problem, and people are discussing it, so suggest
to read previous discussions first before post your V2.

Below link is one I remembered, but I think you can find more:

https://lkml.org/lkml/2013/8/11/100

> This is all dependent on what the dev.id is of udev.

I am not sure why it depends on udev, and udev can't
see the device util it is added to system.

Thanks,
-- 
Ming Lei
