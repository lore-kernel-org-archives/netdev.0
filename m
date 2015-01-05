From: Kalle Valo <kvalo@qca.qualcomm.com>
Subject: Re: [PATCH] net: wireless: rtlwifi: btcoexist: halbtc8821a2ant: Remove some unused functions
Date: Mon, 5 Jan 2015 12:28:48 +0200
Message-ID: <87d26t34in.fsf@kamboji.qca.qualcomm.com>
References: <1420230361-1862-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
	<54A786A4.2050202@lwfinger.net>
	<CAKXHbyOYO29uKA127qyYrCfpgQ2zoqBS9rAJME513oZ8JVdOug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Fengguang Wu <fengguang.wu@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAKXHbyOYO29uKA127qyYrCfpgQ2zoqBS9rAJME513oZ8JVdOug@mail.gmail.com>
	(Rickard Strandqvist's message of "Sat, 3 Jan 2015 13:03:02 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se> writes:

>     I know that you have been told that including "net: wireless:" in the
>     subject line is discouraged. Please do not do this again. The staging
>     directory is different as GregKH uses "staging:" in the subject to route
>     patches, but wireless does not.
>
>     As to the patch, NACK for the simple reason that I am currently working on
>     a number of changes to btcoexist. Some of these routines may end up being
>     removed, but others will not. Having your patch remove them, and one of
>     mine adding them back just constitutes a lot of churning of the source. In
>     addition, it greatly increases the probability of the source trees becoming
>     unsynchronized and getting merge conflicts.
>
> I do not recognize that there has been no diskution on the subject of "net: 
> wireless:"

I mentioned about this in one your earlier patches, but I guess you
didn't get the mail because I got a bounce:

https://lkml.org/lkml/2014/12/24/222

-- 
Kalle Valo
