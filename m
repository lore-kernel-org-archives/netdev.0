From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] brcm80211: brcmsmac: dma: Remove some unused functions
Date: Mon, 05 Jan 2015 12:49:59 +0200
Message-ID: <871tn933jc.fsf@kamboji.qca.qualcomm.com>
References: <1420332469-5907-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<54A8DBF4.4050202@lwfinger.net>
	<CAKXHbyN6LH_pFw1uoLXRzgJv-NcjbTLJvMZXfwYXDwuk9QDszA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Fabian Frederick <fabf@skynet.be>,
	"linux-wireless\@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	brcm80211-dev-list@broadcom.com,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKXHbyN6LH_pFw1uoLXRzgJv-NcjbTLJvMZXfwYXDwuk9QDszA@mail.gmail.com>
	(Rickard Strandqvist's message of "Sun, 4 Jan 2015 13:43:59 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se> writes:

> As I hope you can see I have made some changes regarding the
> subject-line. Thought it was an advantage to be able to see which file
> I actually removed something from. There seems to be a big focus on
> getting right on subject-line right in recent weeks.
>
> I wonder why there is a script that takes a file name, and respond
> with an appropriate subject line?

I don't think you can really automate this as some drivers do this a bit
differently. You always need to manually check the commit log.

> But ok, I change my script accordingly. Should I submit the patch again?

Yes, please resubmit.

-- 
Kalle Valo
