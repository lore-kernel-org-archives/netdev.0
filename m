From: "'Dave Young'" <dyoung@redhat.com>
Subject: Re: nf_reject_ipv4: module license 'unspecified' taints kernel
Date: Tue, 14 Oct 2014 16:12:34 +0800
Message-ID: <20141014081234.GB5357@dhcp-16-198.nay.redhat.com>
References: <20141010091904.GD1981@darkstar.nay.redhat.com>
 <063D6719AE5E284EB5DD2968C1650D6D174C8305@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "pablo@netfilter.org" <pablo@netfilter.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D174C8305@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/10/14 at 09:53am, David Laight wrote:
> From: Dave Young
> > With today's linus tree, I got below kmsg:
> > [   23.545204] nf_reject_ipv4: module license 'unspecified' taints kernel.
> > [   23.551886] Disabling lock debugging due to kernel taint
> ...
> 
> Not 100% related, but why does loading a non-GPL module disable 
> lock debugging?
> (Is 'lock debugging' actually useful?)

I believe that we can not trust the debugging any more because kernel taint.. 

Thanks
Dave
