From: Bryan O'Donoghue <pure.logic@nexus-software.ie>
Subject: Re: [PATCH 0/1] stmmac: rmmod oops after ifconfig on interface
Date: Mon, 13 Apr 2015 13:29:09 +0100
Message-ID: <552BB695.9090508@nexus-software.ie>
References: <1428923713-2419-1-git-send-email-pure.logic@nexus-software.ie> <CAHp75VfunOA4=x9y_XV2J7rLB=+fmkHJc+bm+fnGZWv7-ncLeQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"Ong, Boon Leong" <boon.leong.ong@intel.com>,
	dan.odonovan@emutex.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75VfunOA4=x9y_XV2J7rLB=+fmkHJc+bm+fnGZWv7-ncLeQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/04/15 12:34, Andy Shevchenko wrote:
> On Mon, Apr 13, 2015 at 2:15 PM, Bryan O'Donoghue
> <pure.logic@nexus-software.ie> wrote:
>> We have an oops with stmmac on Quark X1000/Galileo, triggered by rmmod after
>> ifconfig. Patch included in the follow-on email to address.
>
> Can we switch to devm_mdiobus_alloc() in a separate patch ?

Sure np.
