From: Christian <evil@g-house.de>
Subject: Re: 2.6.15-rc1: NET_CLS_U32 not working?
Date: Thu, 17 Nov 2005 01:06:38 +0100
Message-ID: <437BC98E.9020002@g-house.de>
References: <437BBC59.70301@g-house.de> <20051116235813.GS5735@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161038AbVKQAHx@vger.kernel.org>
To: linux-kernel@vger.kernel.org
In-Reply-To: <20051116235813.GS5735@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk schrieb:
> 
> I'm assuming you are trying to insert the new module in your old kernel?

yes, i tried to "modprobe" the compiled cls_u32 module. but the "make 
modules" errors are there anyway. i tried to compile a fresh 2.6.15-rc1 
on a different machine (where i can't do "modprobe") and the errors were 
there too: http://nerdbynature.de/bits/sheep/2.6.15-rc1/make-modules.log

> This is one of the unfortunate but hardly avoidable cases where adding a 
> module requires installing a new kernel.

despite of the errors on "make modules" i'll reboot with the "new" 
kernel asap.

> BTW: Please Cc netdev@vger.kernel.org on networking issues.

ok, will do that.


thank you,
Christian.
-- 
BOFH excuse #442:

Trojan horse ran out of hay
