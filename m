From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] ath5k: Change led pin configuration for compaq c700 laptop
Date: Mon, 04 Apr 2016 18:03:36 +0300
Message-ID: <87vb3xct6f.fsf@kamboji.qca.qualcomm.com>
References: <830d8fa0b7cb0b8cfb0b34360925cd50c3187341.1457977047.git.joseph.salisbury@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jirislaby@gmail.com, mickflemm@gmail.com, mcgrof@do-not-panic.com,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Joseph Salisbury <joseph.salisbury@canonical.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <830d8fa0b7cb0b8cfb0b34360925cd50c3187341.1457977047.git.joseph.salisbury@canonical.com>
	(Joseph Salisbury's message of "Mon, 14 Mar 2016 14:51:48 -0400")
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joseph Salisbury <joseph.salisbury@canonical.com> writes:

> BugLink: http://bugs.launchpad.net/bugs/972604
>
> Commit 09c9bae26b0d3c9472cb6ae45010460a2cee8b8d ("ath5k: add led pin 
> configuration for compaq c700 laptop") added a pin configuration for the Compaq 
> c700 laptop.  However, the polarity of the led pin is reversed.  It should be 
> red for wifi off and blue for wifi on, but it is the opposite.  This bug was 
> reported in the following bug report: 
> http://pad.lv/972604
>
>
> Fixes: 09c9bae26b0d3c9472cb6ae45010460a2cee8b8d ("ath5k: add led pin 
> configuration for compaq c700 laptop")
>
> Signed-off-by: Joseph Salisbury <joseph.salisbury@canonical.com>
> Cc: stable@vger.kernel.org

Applied to ath.git, thanks.

I just fixed the Fixes line to be one continuous line.

-- 
Kalle Valo
