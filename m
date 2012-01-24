From: "Torne (Richard Coles)" <torne@google.com>
Subject: Re: [PATCH] r8169: Randomise invalid MAC addresses
Date: Tue, 24 Jan 2012 13:29:56 +0000
Message-ID: <CAEV-rjeMoC5tK48Y7JKb9NHzOhjSLE+bHt9QNqsZrB0qSmjHtg@mail.gmail.com>
References: <1327343540-30348-1-git-send-email-torne@google.com>
	<CAP=VYLqpUun0FtCs4VWDeLm-mAri=+UV3psRA12eVbV1So_c-Q@mail.gmail.com>
	<CAEV-rjeC1NwbUwdmEEquGf7S8uttsW5hwTjF5nTC_JXY7=OC9A@mail.gmail.com>
	<20120123214318.7183775c@pyramind.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Paul Gortmaker <paul.gortmaker@gmail.com>, nic_swsd@realtek.com,
	romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120123214318.7183775c@pyramind.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23 January 2012 21:43, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
>> So, is this just not going to be acceptable in any form? What about
>> refactoring the existing drivers that do this so that this code
>> doesn't need to be repeated in every driver, if that would help? I'd
>> really quite like to get standard linux distros to be compatible with
>> the Joggler, and this is one of the few changes that's actually needed
>> (one way or another).
>
> It ought to be about a ten line change in Red Hat/Fedora, you could also
> do it generically for most distributions as a udev rule.

OK; I'll work on that instead. Thanks for the feedback all.

-- 
Torne (Richard Coles)
torne@google.com
