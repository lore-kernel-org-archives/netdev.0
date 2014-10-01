From: Chuck Ebbert <cebbert.lkml@gmail.com>
Subject: Re: [LKP] [net] 4ed2d765dfa:  ltp.recv01.4.TFAIL
Date: Wed, 1 Oct 2014 11:20:39 -0500
Message-ID: <20141001112039.375338a0@as>
References: <20141001152910.GA4440@wfg-t540p.sh.intel.com>
	<542C2460.8020208@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Fengguang Wu <fengguang.wu@intel.com>,
	Willem de Bruijn <willemb@google.com>,
	Dave Hansen <dave.hansen@intel.com>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, lkp@01.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <542C2460.8020208@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 01 Oct 2014 17:57:20 +0200
Daniel Borkmann <dborkman@redhat.com> wrote:

> On 10/01/2014 05:29 PM, Fengguang Wu wrote:
> > Hi Willem,
> >
> > FYI, we noticed the below LTP failures on commit
> >
> > 4ed2d765dfaccff5ebdac68e2064b59125033a3b ("net-timestamp: TCP timestamping")
> 
> I think it already was discussed here:
> 
>    http://www.spinics.net/lists/netdev/msg297822.html


I've fixed one of those in LTP.

My proposed patch for how to fix the other three didn't get any replies
on the LTP list:

http://sourceforge.net/p/ltp/mailman/message/32866727/
