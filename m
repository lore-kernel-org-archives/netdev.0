From: "Alejandro Bonilla" <abonilla@linuxwireless.org>
Subject: IPW2100 Kconfig is WRONG!
Date: Fri, 7 Oct 2005 11:54:53 -0400
Message-ID: <20051007154953.M47622@linuxwireless.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
Cc: netdev@vger.kernel.org, jketreno@linux.intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030469AbVJGPy7@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

AGAIN, the location that the Kconfig of ipw2100 says to put the FW in
2.6.14-rc3-Git is WRONG. It should be /lib/firmware, not /etc/firmware.

I have already sent a patch with this and Jesper Juhl also signed it and sent
one in too. What did I/Jesper did wrong?

.Alejandro
