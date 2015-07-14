From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 2/2] isdn/gigaset: drop unused ldisc methods
Date: Tue, 14 Jul 2015 21:03:24 +0200
Message-ID: <1436900604.2679.49.camel@tiscali.nl>
References: <cover.1436826434.git.tilman@imap.cc>
	 <40ceea060d328b84da061f115e7ed9b99d28cf74.1436826434.git.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Hansjoerg Lipp <hjlipp@web.de>, linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <40ceea060d328b84da061f115e7ed9b99d28cf74.1436826434.git.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On di, 2015-07-14 at 00:37 +0200, Tilman Schmidt wrote:
> The line discipline read and write methods are optional so the dummy
> methods in ser_gigaset are unnecessary and can be removed.
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Applied.

I hope to forward this in a few weeks so that it might be in time for
v4.3.

Thanks,


Paul Bolle
