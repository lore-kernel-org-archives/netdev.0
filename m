From: Mateusz Berezecki <mateuszb+lkml@gmail.com>
Subject: memory allocation for DMA operations from network interface
Date: Sun, 27 Nov 2005 19:06:44 +0100
Message-ID: <aec8d6fc0511271006v265a3537r6a90e7d53f706d26@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751131AbVK0SGr@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello List,

My question is about DMA transfers from network device. I suspect
these transfers require allocating physically contiguous memory 
blocks. What is the proper way to allocate such contiguous memory for
DMA purposes inside the kernel? Also what is the proper and
architecture independent way to convert virtual address to physical
one?


kind regards
Mateusz Berezecki
