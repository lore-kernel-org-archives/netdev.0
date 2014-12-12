From: Sriram Raghunathan <sriram.r@nsn.com>
Subject: About ARP state change from Delay to Stale
Date: Fri, 12 Dec 2014 23:07:16 +0530
Message-ID: <548B27CC.2060507@nsn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

    I'd a question about ARP entry state change from DELAY to STALE. I'm
    referring to 3.10 Master kernel, where this particular state change 
is not notified on neigh_update. In  case, on creating a patch for the 
same, would it affect the kernel behavior ?

    Could you please share as why this state change is not notified 
right now?

Sriram
