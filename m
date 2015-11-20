From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH v2 23/27] rt2x00: move under ralink vendor directory
Date: Fri, 20 Nov 2015 11:29:04 +0200
Message-ID: <87twoht3xb.fsf@kamboji.qca.qualcomm.com>
References: <1447857966-19560-1-git-send-email-kvalo@codeaurora.org>
	<1447857966-19560-24-git-send-email-kvalo@codeaurora.org>
	<20151119220522.24fa2733@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jakub Kicinski <moorray3@wp.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151119220522.24fa2733@laptop> (Jakub Kicinski's message of
	"Thu, 19 Nov 2015 22:05:22 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jakub Kicinski <moorray3@wp.pl> writes:

> On Wed, 18 Nov 2015 16:46:02 +0200, Kalle Valo wrote:
>> Part of reorganising wireless drivers directory and Kconfig.
>> 
>> Signed-off-by: Kalle Valo <kvalo@codeaurora.org>
>
> For Ralink you could probably drop the rt2x00 directory.  RaLink Tech.
> doesn't exist any more and rt2x00 contains drivers for all of their
> devices.
>
> Obviously this is just a suggestion, not a show stopper.

Like I said with a similar comment to brcm80211 I would like to do that
separately. This is 27 patches already and I don't want make these any
more complicated than necessary.

-- 
Kalle Valo
