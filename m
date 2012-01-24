From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Randomise invalid MAC addresses
Date: Tue, 24 Jan 2012 19:28:26 +0100
Message-ID: <20120124182826.GA24128@electric-eye.fr.zoreil.com>
References: <1327343540-30348-1-git-send-email-torne@google.com> <20120123212914.747c852f@pyramind.ukuu.org.uk> <20120124171546.GA32184@atrey.karlin.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"Torne (Richard Coles)" <torne@google.com>, nic_swsd@realtek.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120124171546.GA32184@atrey.karlin.mff.cuni.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Machek <pavel@ucw.cz> :
[...]
> Kernel should provide hw abstraction, and that should mean doing
> something about commonly-bad ethernet cards.

Ask for a refund ?

> Userspace does not quite cut it, think about nfsroot for example.

nfsroot without pxe or such ? A bit contrieved imho.

The eeprom may be writable though. Or not :o/

-- 
Ueimor
