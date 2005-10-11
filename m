From: Alejandro Bonilla Beeche <abonilla@linuxwireless.org>
Subject: IPW Question on menuconfig
Date: Mon, 10 Oct 2005 21:00:50 -0600
Message-ID: <434B2AE2.1070709@linuxwireless.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Ketrenos <jketreno@linux.intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751362AbVJKDAy@vger.kernel.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

    I was just git updating 2.6.14-rc4 and I didn't have the 
CONFIG_IEEE80211 module selected, then I went into Device Drivers / 
Network devices / Wireless, and the IPW2100 wasn't in the list. I went, 
then Modularized the IEEE80211 and then IPW2100 was there. I think is 
kind of estrange that IPW2100 wouldn't show just because it has a 
dependencie, shouldn't IPW2100 show in the list, and if you select it, 
then it would also select CONFIG_IEEE80211?

Just a dumb question cause I dunno how is normally done or the policy to 
do this.

.Alejandro
