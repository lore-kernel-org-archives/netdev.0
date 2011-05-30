From: Arun Sharma <asharma@fb.com>
Subject: Re: Kernel crash after using new Intel NIC (igb)
Date: Mon, 30 May 2011 11:34:22 -0700
Message-ID: <4DE3E32E.5000302@fb.com>
References: <4DDEEBC5.80804@fb.com> <1306466831.2543.58.camel@edumazet-laptop> <4DDFE4D6.4010000@fb.com> <1306526219.2533.3.camel@edumazet-laptop> <20110527211419.GA6793@dev1756.snc6.facebook.com> <1306561285.2533.9.camel@edumazet-laptop> <20110528180434.GB12530@elte.hu> <1306654424.30021.7.camel@edumazet-laptop> <20110529073840.GB21254@elte.hu> <1306654983.30021.10.camel@edumazet-laptop> <20110529123318.GB26627@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Maximilian Engelhardt <maxi@daemonizer.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	StuStaNet Vorstand <vorstand@stusta.mhn.de>,
	Yann Dupont <Yann.Dupont@univ-nantes.fr>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	Thomas Gleixner <tglx@linutronix.de>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110529123318.GB26627@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/29/11 5:33 AM, Ingo Molnar wrote:
>
> * Eric Dumazet<eric.dumazet@gmail.com>  wrote:
>
>> I asked Arun if he wanted to make this himself, because initial
>> idea was coming from him, not because I did not want to make it ;)
>
> Hey, fair enough and sorry about the fuss! :-)

Sounds like there is general consensus that such a cleanup would be 
good. I'll try to post a patch that does this cleanup for all archs in 
the next couple of days - but I won't have a way of testing it on 
anything other than x86_64.

  -Arun
