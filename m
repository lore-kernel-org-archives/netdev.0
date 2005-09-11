From: Daniel Drake <dsd@gentoo.org>
Subject: Re: Very strange Marvell/Yukon Gigabit NIC networking problems
Date: Sun, 11 Sep 2005 16:24:35 +0100
Message-ID: <43244C33.1050502@gentoo.org>
References: <20050901212110.19192.qmail@web53605.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	linux-kernel@vger.kernel.org, Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964814AbVIKPYj@vger.kernel.org>
To: Steve Kieu <haiquy@yahoo.com>
In-Reply-To: <20050901212110.19192.qmail@web53605.mail.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Steve Kieu wrote:
> If run 2.6.13 and up the NIC, it is working. Shuttdown
> or reboot using /sbin/halt (means power completely off
> and on) or /sbin/reboot all other OSs failed to enable
> the NIC except 2.6.13.
> 
> to restore the normal working of the NIC, boot 2.6.13
> and do a hot power reset. (press the reset button)

Stephen recently posted a patch which looks like it might solve this issue.

Steve, maybe you could test it out? I have attached it to this Gentoo bug:

	http://bugs.gentoo.org/100258

Stephen, thanks for your hard work!
Daniel
