From: Thomas Backlund <tmb@mandriva.org>
Subject: Re: [33-stable regression ssb/broadcom]
Date: Mon, 13 Sep 2010 23:34:10 +0300
Message-ID: <4C8E8AC2.2030201@mandriva.org>
References: <4C8E6192.2010003@mandriva.org> <20100913.122329.39186333.davem@davemloft.net> <20100913193647.GD4052@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"stable@kernel.org" <stable@kernel.org>,
	"gregkh@suse.de" <gregkh@suse.de>,
	"Larry.Finger@lwfinger.net" <Larry.Finger@lwfinger.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100913193647.GD4052@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville skrev 13.9.2010 22:36:
> On Mon, Sep 13, 2010 at 12:23:29PM -0700, David Miller wrote:
>> From: Thomas Backlund<tmb@mandriva.org>
>> Date: Mon, 13 Sep 2010 20:38:26 +0300
>>
>>> In Mandriva 2010.1 we noticed that 2.6.33.7 broke ssb/Broadcom lan for
>>> several users...
>>>
>>> Issue is tracked at:
>>> https://qa.mandriva.com/show_bug.cgi?id=60968
>>>
>>> Reverting the commit restores a working lan.
>>>
>>> The offending commit is:
>>
>> Please always CC: netdev on networking reports, otherwise you are
>> very unlikely to get any experts looking into your issue.
>
> IIRC, there was a bad patch that got sent for the 2.6.33.y series.
> I thought it had been reverted or fixed already?
>

Nope.

It got added in 2.6.33.7
http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.33.y.git;a=commit;h=6fb037c2ed8378c7ab0c1e00536ba6b2a866503e

--
Thomas
