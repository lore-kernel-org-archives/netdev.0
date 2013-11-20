From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Workaround for Suspend/Resume issue of AX88772B
 under ChromeOS
Date: Wed, 20 Nov 2013 13:54:13 -0500 (EST)
Message-ID: <20131120.135413.920731121262719289.davem@davemloft.net>
References: <1384913496-26261-1-git-send-email-freddy@asix.com.tw>
	<20131120.004026.2013972041095203460.davem@davemloft.net>
	<CANEJEGtBmvFNcFzOW9ZnOFd=ZMnz82ajcN52YqW3+n0+=rhxBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: freddy@asix.com.tw, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	davemloft@davemloft.net, louis@asix.com.tw, allan@asix.com.tw,
	daniel@asix.com.tw
To: grundler@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANEJEGtBmvFNcFzOW9ZnOFd=ZMnz82ajcN52YqW3+n0+=rhxBA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@google.com>
Date: Wed, 20 Nov 2013 09:42:42 -0800

> While this patch raises a new issue, can you apply this patch anyway
> since in most cases (default settings) it improves "the user
> experience" for most users?

I'm not applying a patch which knowingly is not implemented correctly.
