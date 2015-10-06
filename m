From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH v2] Documentation: improve line discipline method
 descriptions
Date: Tue, 06 Oct 2015 22:24:58 +0200
Message-ID: <1444163098.2417.53.camel@tiscali.nl>
References: <d43bc9f8bddbd7ce07200a8a149ae15e5eac5d6d.1436827841.git.tilman@imap.cc>
	 <1436901132.2679.54.camel@tiscali.nl>
	 <1349c282fb3642264c7c8c1478ce8a0dcdd93aef.1443569708.git.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Hurley <peter@hurleysoftware.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349c282fb3642264c7c8c1478ce8a0dcdd93aef.1443569708.git.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tilman,

On wo, 2015-09-30 at 01:45 +0200, Tilman Schmidt wrote:
> --- a/Documentation/serial/tty.txt
> +++ b/Documentation/serial/tty.txt

> +			Should [...] set receive_room
> +			in the tty_struct to the maximum amount of data
> +			the line discipline is willing to accept from the
> +			driver with a single call to receive_buf().

A lot clearer than v1! (I do assume the TTY people will shout if that
sentence isn't actually correct.)

Thanks for looking into this, again.


Paul Bolle
