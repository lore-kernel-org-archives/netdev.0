From: Lan Xue <lanxue@soe.ucsc.edu>
Subject: global memory access
Date: Sat, 4 Dec 2004 14:05:00 -0800 (PST)
Message-ID: <Pine.GSO.4.58.0412041401570.28362@moondance.cse.ucsc.edu>
References: <20041202094433.39132.qmail@web41411.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kernerl mail <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261177AbULDWFF@vger.kernel.org>
To: netdev@oss.sgi.com
In-Reply-To: <20041202094433.39132.qmail@web41411.mail.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I was wondering how a user-level program can share a writable memory
buffer with the kernel. The memory can either belongs to the kernel space
or the user space, but both kernel module and user program should be able
to access(read, write) it.

Any hint? Many thanks,

Lan
