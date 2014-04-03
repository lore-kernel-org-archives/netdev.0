From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: Bug(s) with netconsole (using mv643xx_eth on Kirkwood)
Date: Thu, 03 Apr 2014 20:39:19 +0200
Message-ID: <533DAAD7.40000@ahsoftware.de>
References: <1396396559-6971-1-git-send-email-holler@ahsoftware.de> <CAGVrzcZd9tBtcTY_2PRHVb9kJAjVHqn+EubUy4NGL66M_UuCDg@mail.gmail.com> <533BD3CD.1010905@ahsoftware.de> <CAGVrzcZi5aNq8fR795fKhu2TAc1tQCa2YEorErZRLf2n9DPZuw@mail.gmail.com> <533C721E.1080004@gmail.com> <533C8B49.8080704@ahsoftware.de> <533C8ECB.4090900@gmail.com> <533D0B09.9040602@ahsoftware.de> <533D207E.9020909@gmail.com> <533D790C.5000104@ahsoftware.de> <533D8207.2050108@gmail.com> <533D8518.1010306@ahsoftware.de> <533DA12B.8090904@ahsoftware.de> <533DA69A.2010402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>,
	David Miller <davem@davemloft.net>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <533DA69A.2010402@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 03.04.2014 20:21, schrieb Sebastian Hesselbarth:
> On 04/03/2014 07:58 PM, Alexander Holler wrote:

>> I hope everyone who missed some more information is happy now, otherwise
>> I (again) wasted time to type a problem description (not to speak about
>> the already spent time trying to diagnose the problem)
>>
>> So go on and try to take the almost low hanging fruit. I'm not sure if I
>> will spend more time on that topic as I already have a working
>> patch/workaround and the discussion has become a bit tiresome. Sorry.
>
> Alexander, please stop f*cking around here. Florian, David, and me
> already showed a lot patience. None of your patches deals with the
> real issue. Either help others to properly reproduce it or leave it.

I haven't requested help.

I've send a patch which fixed a problem here I had with a new reset. The 
problem appears inside the reset (the reset doesn't end), so the patch 
looked very reasonable. That's all.

And, please, keep your words where they belong to.

Alexander Holler
