From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 33332] IC Plus Corp IP1000 Family Gigabit Ethernet and
 OpenSuSE (x86, x86_64)
Date: Thu, 18 Jul 2013 16:24:45 -0700
Message-ID: <20130718162445.51c426af@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f194.google.com ([209.85.192.194]:39499 "EHLO
	mail-pd0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934728Ab3GRXYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 19:24:49 -0400
Received: by mail-pd0-f194.google.com with SMTP id 10so1327860pdi.5
        for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 16:24:48 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-71-109.bvtn.or.frontiernet.net. [50.53.71.109])
        by mx.google.com with ESMTPSA id il4sm15942609pbb.36.2013.07.18.16.24.47
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 18 Jul 2013 16:24:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 18 Jul 2013 15:49:18 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 33332] IC Plus Corp IP1000 Family Gigabit Ethernet and OpenSuSE (x86, x86_64)


https://bugzilla.kernel.org/show_bug.cgi?id=33332

David Barnes <dnsenrab@yahoo.com> changed:

           What    |Removed                     |Added
----------------------------------------------------------------------------
                 CC|                            |dnsenrab@yahoo.com

--- Comment #6 from David Barnes <dnsenrab@yahoo.com> ---
(In reply to Alan from comment #5)
> Is this still seen in modern (3.2+) kernels ?

Linux 3800LU64 3.2.0-48-generic #74-Ubuntu SMP Thu Jun 6 19:43:26 UTC 2013
x86_64 x86_64 x86_64 GNU/Linux

- Device: eth1  [Wired connection 1]
-------------------------------------------
  Type:              Wired
  Driver:            Sundance Technology IPG Triple-Speed Ethernet
  State:             connected
  Default:           yes
  HW Address:        F4:6D:04:AB:24:CB

product: IP1000 Family Gigabit Ethernet [13F0:1023]
vendor: Sundance Technology Inc / IC Plus Corp [13F0]
bus info: pci@0000:01:08.0
logical name: eth1
version: 41
serial: f4:6d:04:ab:24:cb
size: 100Mbit/s
capacity: 100Mbit/s
width: 32 bits
clock: 66MHz



Still a bug.

-- 
You are receiving this mail because:
You are the assignee for the bug.
