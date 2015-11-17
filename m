From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Tue, 17 Nov 2015 20:43:31 +0100 (CET)
Message-ID: <alpine.DEB.2.11.1511172041480.3761@nanos>
References: <564B3D35.50004@profihost.ag> <alpine.DEB.2.11.1511171936030.3761@nanos> <564B7F9D.5060701@profihost.ag>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stefan Priebe <s.priebe@profihost.ag>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564B7F9D.5060701@profihost.ag>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 17 Nov 2015, Stefan Priebe wrote:
> I've now also two gdb backtraces from two crashes:
> http://pastebin.com/raw.php?i=yih5jNt8
> 
> http://pastebin.com/raw.php?i=kGEcvH4T

They don't tell me anything as I have no idea of the inner workings of
asterisk. You might be better of to talk to the asterisk folks to help
you track down what that thing is waiting for, so we can actually look
at a well defined area.

Thanks,

	tglx
