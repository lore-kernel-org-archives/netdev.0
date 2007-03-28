From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [2.6 patch] the scheduled eepro100 removal
Date: Wed, 28 Mar 2007 18:17:59 -0400
Message-ID: <460AE997.90509@tmr.com>
References: <20070325145810.GI16477@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933875AbXC1WRy@vger.kernel.org>
In-Reply-To: <20070325145810.GI16477@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch contains the scheduled removal of the eepro100 driver.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> 
This keeps coming around, but I haven't seen an answer to the questions 
raised by Eric Piel or Kiszka. I do know that e100 didn't work on some 
IBM rackmount servers and eepro100 did, but since I'm no longer 
responsible for those machines I can't retest. Perhaps someone will be 
able to provide data points.

IBM current offerings as of about three years ago, I had a few dozen of 
them at one time.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot
