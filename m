From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v3 9/9] selinux: use generic union inet_addr
Date: Thu, 22 Aug 2013 13:03:48 +0800
Message-ID: <1377147828.8703.13.camel@cr0>
References: <1376907278-26377-1-git-send-email-amwang@redhat.com>
	  <1376907278-26377-10-git-send-email-amwang@redhat.com>
	  <52127336.3080209@schaufler-ca.com>
	  <20130819.125026.636442915180863272.davem@davemloft.net>
	  <5212915F.20905@schaufler-ca.com> <1377003677.13412.5.camel@cr0>
	 <52137CFF.70601@schaufler-ca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	james.l.morris@oracle.com, sds@tycho.nsa.gov,
	eparis@parisplace.org, pmoore@redhat.com,
	linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org
To: Casey Schaufler <casey@schaufler-ca.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52137CFF.70601@schaufler-ca.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-08-20 at 07:28 -0700, Casey Schaufler wrote:
> 
> I do use and enjoy all of these implementations! Thank you
> for the fine implementations. In the end, if you're maintaining
> the code it's your call. I question change that does not have
> an obvious purpose because statistically every 10th change has
> a bug. 

Sure, feel free to add more.

And please reject all new code >=10 changes in the future too... I give
up, you win. :-)
