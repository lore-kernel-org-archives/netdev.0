From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: RFC [PATCH] iproute2: temporary solution to fix xt breakage
Date: Tue, 18 Dec 2012 07:28:39 -0500
Message-ID: <50D06177.2090905@mojatatu.com>
References: <50C4821D.5090206@gmail.com> <50C9B4BB.9060609@mojatatu.com> <50CCE961.5050204@mojatatu.com> <alpine.LNX.2.01.1212160002330.4901@nerf07.vanv.qr> <CAASe=fQT2pVOK0uctdaKL+aOrF8nYeTMfoF15kmd-rC02+7Vnw@mail.gmail.com> <50CDFB6A.3090806@mojatatu.com> <50CE1A04.1000405@mojatatu.com> <alpine.LNX.2.01.1212162003340.27614@nerf07.vanv.qr> <50CE3203.9080007@mojatatu.com> <50CF1071.1050405@mojatatu.com> <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jan Engelhardt <jengelh@inai.de>,
	Yury Stankevich <urykhy@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	pablo@netfilter.org, netfilter-devel@vger.kernel.org
To: Hasan Chowdhury <shemonc@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAASe=fRuJdtisEvp7uo=PHwN3nKHqsYDW4Om1gk2MK-vyNvBrA@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12-12-17 11:10 AM, Hasan Chowdhury wrote:
> Juts noticed , the attached patch does not have the modification for
> m_xt.c , without it   ,I guess this patch  is not going  to work.


Thats in the first patch i sent out which I hope Stephen will apply
right away.
This one depends on that. So you must apply that patch, then this.

cheers,
jamal


