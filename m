From: Meelis Roos <mroos@linux.ee>
Subject: Q: ieee80211_txb
Date: Sun, 29 May 2005 13:47:34 +0300 (EEST)
Message-ID: <Pine.SOC.4.61.0505291343360.4341@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I tried to understand the new 802.11 stack API and met some things I 
couldn't understand by just looking at the code.

My main question is currently struct ieee80211_txb. How is it meant to 
be used? How driver-specific is it - should it fit all drivers or does 
it assume some specific DMA set-up?

-- 
Meelis Roos (mroos@linux.ee)
