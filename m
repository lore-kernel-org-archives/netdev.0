From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: missing in stable 4.1.1 - was Re: pull-request: can 2015-06-21
Date: Tue, 30 Jun 2015 22:28:08 +0200
Message-ID: <5592FBD8.4090209@hartkopp.net>
References: <1434906299-19452-1-git-send-email-mkl@pengutronix.de> <20150623.064338.1193972764545855895.davem@davemloft.net> <5592EE98.8030705@hartkopp.net> <20150630200713.GA10747@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, David Miller <davem@davemloft.net>,
	mkl@pengutronix.de, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, kernel@pengutronix.de
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150630200713.GA10747@kroah.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30.06.2015 22:07, Greg KH wrote:
> On Tue, Jun 30, 2015 at 09:31:36PM +0200, Oliver Hartkopp wrote:

>> The upstream commit is:
>>
>> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=36c01245eb8046c16eee6431e7dbfbb302635fa8
>>
>> which slipped into 4.2 at merge window opening time.
>>
>> So it just got lost in the stable queue somehow.
>
> No, it's still there.  I don't queue up patches for a stable release
> until they have shown up in a public release from Linus.  So in this
> case, it will be elgible to be in a stable kernel after 4.2-rc1 is out.
>
> Unless you tell me otherwise, so if you want this in the next 4.1-stable
> release, I can queue it up now.

I would really appreciate it if you can queue it up now.

We already had a bug report for 4.1.0 which is fixed by this patch.

Thanks & best regards,
Oliver
