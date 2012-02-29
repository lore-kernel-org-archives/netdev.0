From: "Huang, Xiong" <xiong@qca.qualcomm.com>
Subject: RE: [PATCH] net: add QCA alx Ethernet driver
Date: Wed, 29 Feb 2012 03:11:14 +0000
Message-ID: <157393863283F442885425D2C454285619415561@nasanexd02a.na.qualcomm.com>
References: <20120228.205347.1718771650331094141.davem@davemloft.net>
	<CAB=NE6VXyQ-k1Sm3Xf_ABE35+PHSoNqX=AJpLBjNu0sdAdnY4g@mail.gmail.com>
	<157393863283F442885425D2C4542856194154FC@nasanexd02a.na.qualcomm.com>
 <20120228.212857.797446903975232476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Rodriguez, Luis" <rodrigue@qca.qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>,
	"Giori, Kathy" <kgiori@qca.qualcomm.com>,
	"chris.snook@gmail.com" <chris.snook@gmail.com>,
	"Olivari, Mathieu" <mathieu@qca.qualcomm.com>,
	"Huntsman, Bryan" <bryanh@quicinc.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120228.212857.797446903975232476.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

    We understand your concern.  To support the new chipset,  do you think it's reasonable to upstream  it as a new driver, not a replacement ?

Thanks
Xiong

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, February 29, 2012 10:29
> To: Huang, Xiong
> Cc: Rodriguez, Luis; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> qca-linux-team; nic-devel; Giori, Kathy; chris.snook@gmail.com; Olivari,
> Mathieu; Huntsman, Bryan
> Subject: Re: [PATCH] net: add QCA alx Ethernet driver
> 
> From: "Huang, Xiong" <xiong@qca.qualcomm.com>
> Date: Wed, 29 Feb 2012 02:19:05 +0000
> 
> >      The code related to hardware of atl1c is quite diff with that in
> > our hand, every time we take much time to find which part should be
> > revised for one bug/issue found on other platform/OSes. the new driver
> > make it easy to fix and support new chipset as well.
> 
> Broadcom gave the same excuses.  Save yourself some typing.
> 
> I already know what you are going to say and claim are the issues.
> 
> I've heard it all before, and none of them justify replacing the existing driver
> wholesale.  We simply don't operate this way.
> 
> Because you guys didn't upstream your driver properly back when the atl1c
> hardware first came out and Linux needed a driver, someone else did.
> 
> And we're not removing their driver just because now you guys just want to
> come in and take over simply because you're not willing to collaborate properly
> and contribute to the existing code like everyone else on the planet does.
> 
> There is no arguing against this, there is no justification, and it simply will not
> happen.  I'm sorry you put some must effort into this but you should have been
> smart and listened to Luis last year when he tried to guide you in the right
> direction.
> 
> Listening to Luis would have saved you a lot of wasted engineering.
> 
> Maybe you will be smart and listen to him next time.
