From: Chinmaya Mishra <chinmaya@innomedia.soft.net>
Subject: Kernel panic occurs with ucdsnmp
Date: Mon, 18 Sep 2006 11:56:18 +0530
Message-ID: <450E3C0A.20406@innomedia.soft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from [220.227.188.61] ([220.227.188.61]:60049 "EHLO
	gateway.innomedia.soft.net") by vger.kernel.org with ESMTP
	id S965435AbWIRGQD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 02:16:03 -0400
To: linux-kernel-owner@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi all,

I am trying to compile the uCLinux's distribution with enabling the 
'ucdsnmp'.
It will successfully compiled, image and romfs.img is created.
But when i am trying to boot with this image I am getting the following
error message....

.............................
Other stuff added by David S. Miller <davem@redhat.com>
VFS: Mounted root (romfs filesystem) readonly.
Freeing init memory: 44K
Warning: unable to open an initial console.
Kernel panic: Attempted to kill init!
Panic reset

After this it will halts. If i am not enable the 'ucdsnmp' package it
works fine. What is the resean of this .....

WORNING: UNABLE TO OPEN AN INITIAL CONSOLE.
KERNEL PANIC: ATTEMPTED TO KILL INIT!
PANIC RESET

Please tell me where is the mistake ?

Tahnks in advance.
Chinmaya



