From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add QCA alx Ethernet driver
Date: Tue, 28 Feb 2012 21:28:57 -0500 (EST)
Message-ID: <20120228.212857.797446903975232476.davem@davemloft.net>
References: <20120228.205347.1718771650331094141.davem@davemloft.net>
	<CAB=NE6VXyQ-k1Sm3Xf_ABE35+PHSoNqX=AJpLBjNu0sdAdnY4g@mail.gmail.com>
	<157393863283F442885425D2C4542856194154FC@nasanexd02a.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rodrigue@qca.qualcomm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qca-linux-team@qualcomm.com,
	nic-devel@qualcomm.com, kgiori@qca.qualcomm.com,
	chris.snook@gmail.com, mathieu@qca.qualcomm.com, bryanh@quicinc.com
To: xiong@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <157393863283F442885425D2C4542856194154FC@nasanexd02a.na.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Date: Wed, 29 Feb 2012 02:19:05 +0000

>      The code related to hardware of atl1c is quite diff with that
> in our hand, every time we take much time to find which part should
> be revised for one bug/issue found on other platform/OSes. the new
> driver make it easy to fix and support new chipset as well.

Broadcom gave the same excuses.  Save yourself some typing.

I already know what you are going to say and claim are the issues.

I've heard it all before, and none of them justify replacing the
existing driver wholesale.  We simply don't operate this way.

Because you guys didn't upstream your driver properly back when
the atl1c hardware first came out and Linux needed a driver,
someone else did.

And we're not removing their driver just because now you guys just
want to come in and take over simply because you're not willing to
collaborate properly and contribute to the existing code like everyone
else on the planet does.

There is no arguing against this, there is no justification, and it
simply will not happen.  I'm sorry you put some must effort into this
but you should have been smart and listened to Luis last year when he
tried to guide you in the right direction.

Listening to Luis would have saved you a lot of wasted engineering.

Maybe you will be smart and listen to him next time.
