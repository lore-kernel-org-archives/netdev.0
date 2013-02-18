From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] b43: Increase number of RX DMA slots
Date: Mon, 18 Feb 2013 11:04:00 -0600
Message-ID: <51225F00.9020707@lwfinger.net>
References: <1361156480-32566-1-git-send-email-Larry.Finger@lwfinger.net> <CACna6rwLgE+o2mcRTemLFAqzdsEoA9Xyx8GyEQTh5qbv1iZ04A@mail.gmail.com> <20130218165510.GC8730@medion.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Bastian Bittorf <bittorf@bluebottle.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20130218165510.GC8730@medion.lan>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/18/2013 10:55 AM, Bastian Bittorf wrote:
> * Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> [18.02.2013 17:54]:
>> 2013/2/18 Larry Finger <Larry.Finger@lwfinger.net>:
>>
>> So probably ideal solution is to use 128 *and* fix the driver's
>> failing on overflow ;)
>
> i will run a test tomorrow an report, keep calm.

Do you have debugging turned on for b43? If so, the slot usage line at =
module=20
unload would be useful.

Larry
