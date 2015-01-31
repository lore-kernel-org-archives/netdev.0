From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: Re: [PATCH] net: sched: One function call less in em_meta_change()
 after error detection
Date: Sat, 31 Jan 2015 23:20:25 +0100
Message-ID: <54CD5529.5060209@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net> <54CD042E.6030606@users.sourceforge.net> <54CD115C.8070801@gmx.de> <54CD4D91.9080801@users.sourceforge.net> <54CD5404.1010004@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54CD5404.1010004@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> I find that all these cases correspond to the current Linux coding
>> style documentation, doesn't it?
> 
> Sure, I think it does.

Thanks for your acknowledgement.


> But it was not coding style violation what I was reffering to.

Do you suggest any fine-tuning for the affected documentation
so that I would tweak my update suggestion once more?

Regards,
Markus
